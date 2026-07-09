import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:event_bus/event_bus.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/core/events/products_changed_event.dart';
import 'package:klozy/src/core/events/profile_changed_event.dart';
import 'package:klozy/src/core/events/reels_changed_event.dart';
import 'package:klozy/src/core/pagination/paginated_list.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:klozy/src/domain/product/entity/product.dart';
import 'package:klozy/src/domain/social/entity/profile_reel.dart';
import 'package:klozy/src/domain/social/social_repository.dart';
import 'package:klozy/src/feature/profile/presentation/bloc/profile_event.dart';
import 'package:klozy/src/feature/profile/presentation/bloc/profile_state.dart';
import 'package:klozy/src/feature/profile/presentation/bloc/profile_tab.dart';

@injectable
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final SocialRepository _repository;
  final MeRepository _meRepository;

  final List<StreamSubscription<Object?>> _subscriptions =
      <StreamSubscription<Object?>>[];

  static const int _productsLimit = 20;
  static const int _reelsLimit = 30;
  int _productsPage = 1;
  int _reelsPage = 1;

  ProfileBloc(this._repository, this._meRepository, EventBus eventBus)
    : super(const ProfileLoadingState()) {
    on<ProfileStarted>(_onStarted);
    on<ProfileTabChanged>(_onTabChanged);
    on<ProfileFollowToggled>(_onFollowToggled);
    on<ProfileReported>(_onReported);
    on<ProfileBlocked>(_onBlocked);
    on<ProfileRefreshed>(_onRefreshed);
    on<ProfileProductsLoadMore>(_onProductsLoadMore);
    on<ProfileReelsLoadMore>(_onReelsLoadMore);
    on<ProfilePullToRefresh>(_onPullToRefresh);
    _subscriptions.add(
      eventBus.on<ProductsChangedEvent>().listen(
        (_) => add(const ProfileRefreshed()),
      ),
    );
    _subscriptions.add(
      eventBus.on<ReelsChangedEvent>().listen(
        (_) => add(const ProfileRefreshed()),
      ),
    );
    _subscriptions.add(
      eventBus.on<ProfileChangedEvent>().listen(
        (_) => add(const ProfileRefreshed()),
      ),
    );
  }

  @override
  Future<void> close() {
    for (final StreamSubscription<Object?> sub in _subscriptions) {
      sub.cancel();
    }
    return super.close();
  }

  Future<void> _onStarted(
    ProfileStarted event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoadingState());
    try {
      final profile = event.userId == null
          ? await _repository.getMyProfile()
          : await _repository.getProfile(event.userId!);
      _productsPage = 1;
      PaginatedList<Product> page;
      try {
        page = await _repository.getUserProducts(
          profile.id,
          limit: _productsLimit,
        );
      } catch (_) {
        page = const PaginatedList<Product>(data: <Product>[]);
      }
      emit(
        ProfileLoadedState(
          profile: profile,
          products: page.data,
          productsHasMore: page.data.length >= _productsLimit,
        ),
      );
    } catch (error) {
      emit(ProfileErrorState(type: AppErrorType.fromException(error)));
    }
  }

  Future<void> _onTabChanged(
    ProfileTabChanged event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state;
    if (current is! ProfileLoadedState) return;
    emit(current.copyWith(tab: event.tab));

    final bool needsReels =
        event.tab == ProfileTab.reels && current.reels == null;
    final bool needsReviews =
        event.tab == ProfileTab.reviews && current.reviews == null;
    if (!needsReels && !needsReviews) return;

    emit((state as ProfileLoadedState).copyWith(tabLoading: true));
    try {
      if (needsReels) {
        _reelsPage = 1;
        final page = await _repository.getUserReels(
          current.profile.id,
          mine: current.profile.isMe,
          limit: _reelsLimit,
        );
        emit(
          (state as ProfileLoadedState).copyWith(
            reels: page.data,
            tabLoading: false,
            reelsHasMore: page.data.length >= _reelsLimit,
          ),
        );
      } else {
        final reviews = await _repository.getReviews(current.profile.id);
        emit(
          (state as ProfileLoadedState).copyWith(
            reviews: reviews,
            tabLoading: false,
          ),
        );
      }
    } catch (_) {
      emit((state as ProfileLoadedState).copyWith(tabLoading: false));
    }
  }

  Future<void> _onFollowToggled(
    ProfileFollowToggled event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state;
    if (current is! ProfileLoadedState || current.profile.isMe) return;
    final wasFollowing = current.profile.isFollowing;
    emit(
      current.copyWith(
        profile: current.profile.copyWith(
          isFollowing: !wasFollowing,
          followers: current.profile.followers + (wasFollowing ? -1 : 1),
        ),
      ),
    );
    try {
      if (wasFollowing) {
        await _repository.unfollow(current.profile.id);
      } else {
        await _repository.follow(current.profile.id);
      }
    } catch (_) {
      emit((state as ProfileLoadedState).copyWith(profile: current.profile));
    }
  }

  Future<void> _onReported(
    ProfileReported event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state;
    if (current is! ProfileLoadedState) return;
    try {
      await _repository.reportUser(current.profile.id, 'Reported from app');
    } catch (_) {}
  }

  Future<void> _onBlocked(
    ProfileBlocked event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state;
    if (current is! ProfileLoadedState || current.profile.isMe) return;
    try {
      await _meRepository.block(current.profile.id);
    } catch (_) {}
  }

  /// My listings/reels changed elsewhere — refetch the loaded sections
  /// without flashing a loading state. Only meaningful on my own profile.
  Future<void> _onRefreshed(
    ProfileRefreshed event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state;
    if (current is! ProfileLoadedState || !current.profile.isMe) return;
    try {
      final profile = await _repository.getMyProfile();
      _productsPage = 1;
      final productsPage = await _repository.getUserProducts(
        profile.id,
        limit: _productsLimit,
      );
      List<ProfileReel>? reels;
      bool reelsHasMore = current.reelsHasMore;
      if (current.reels != null) {
        _reelsPage = 1;
        final reelsPage = await _repository.getUserReels(
          profile.id,
          mine: true,
          limit: _reelsLimit,
        );
        reels = reelsPage.data;
        reelsHasMore = reelsPage.data.length >= _reelsLimit;
      }
      final latest = state;
      if (latest is! ProfileLoadedState) return;
      emit(
        latest.copyWith(
          profile: profile,
          products: productsPage.data,
          productsHasMore: productsPage.data.length >= _productsLimit,
          reels: reels ?? latest.reels,
          reelsHasMore: reelsHasMore,
        ),
      );
    } catch (_) {
      // Quiet refresh: keep showing what we have.
    }
  }

  /// Append the next page of products. Guard on
  /// `productsLoadingMore`/`productsHasMore`, flip `productsLoadingMore` true,
  /// fetch page `_productsPage + 1` (limit `_productsLimit`), increment
  /// `_productsPage` on success, then emit appended items with
  /// `productsHasMore = page.data.length >= _productsLimit`. Mirror
  /// FeedBloc._onLoadMore.
  Future<void> _onProductsLoadMore(
    ProfileProductsLoadMore event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state;
    if (current is! ProfileLoadedState ||
        current.productsLoadingMore ||
        !current.productsHasMore) {
      return;
    }
    emit(current.copyWith(productsLoadingMore: true));
    try {
      final page = await _repository.getUserProducts(
        current.profile.id,
        page: _productsPage + 1,
        limit: _productsLimit,
      );
      _productsPage += 1;
      emit(
        current.copyWith(
          products: <Product>[...current.products, ...page.data],
          productsLoadingMore: false,
          productsHasMore: page.data.length >= _productsLimit,
        ),
      );
    } catch (_) {
      emit(current.copyWith(productsLoadingMore: false));
    }
  }

  /// Append the next page of reels. Guard on
  /// `reelsLoadingMore`/`reelsHasMore`, flip `reelsLoadingMore` true, fetch
  /// page `_reelsPage + 1` (limit `_reelsLimit`, `mine: profile.isMe`),
  /// increment `_reelsPage` on success, then emit appended items with
  /// `reelsHasMore = page.data.length >= _reelsLimit`.
  Future<void> _onReelsLoadMore(
    ProfileReelsLoadMore event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state;
    if (current is! ProfileLoadedState ||
        current.reelsLoadingMore ||
        !current.reelsHasMore) {
      return;
    }
    emit(current.copyWith(reelsLoadingMore: true));
    try {
      final page = await _repository.getUserReels(
        current.profile.id,
        mine: current.profile.isMe,
        page: _reelsPage + 1,
        limit: _reelsLimit,
      );
      _reelsPage += 1;
      emit(
        current.copyWith(
          reels: <ProfileReel>[...?current.reels, ...page.data],
          reelsLoadingMore: false,
          reelsHasMore: page.data.length >= _reelsLimit,
        ),
      );
    } catch (_) {
      emit(current.copyWith(reelsLoadingMore: false));
    }
  }

  /// User pull-to-refresh: reset `_productsPage`/`_reelsPage` to 1, emit a
  /// value-distinct state FIRST (e.g. flip the visible tab's `*LoadingMore`
  /// true) so the RefreshIndicator does not hang on an equal emit, refetch the
  /// first page(s) of the visible tab, then emit fresh items with reset
  /// `*HasMore` and cleared `*LoadingMore`. Mirror FeedBloc._onRefreshed.
  Future<void> _onPullToRefresh(
    ProfilePullToRefresh event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state;
    if (current is! ProfileLoadedState) return;
    // Mark in-flight so the result is always a *distinct* state — otherwise an
    // unchanged first page is value-equal to the current state, Bloc drops the
    // emit, and the RefreshIndicator (awaiting the next state) hangs on
    // screen. Flip the currently-visible tab's flag.
    final bool refreshingReels = current.tab == ProfileTab.reels;
    emit(
      current.copyWith(
        productsLoadingMore: !refreshingReels || current.productsLoadingMore,
        reelsLoadingMore: refreshingReels || current.reelsLoadingMore,
      ),
    );
    try {
      final profile = current.profile.isMe
          ? await _repository.getMyProfile()
          : await _repository.getProfile(current.profile.id);
      _productsPage = 1;
      final productsPage = await _repository.getUserProducts(
        profile.id,
        limit: _productsLimit,
      );
      List<ProfileReel>? reels = current.reels;
      bool reelsHasMore = current.reelsHasMore;
      if (current.reels != null) {
        _reelsPage = 1;
        final reelsPage = await _repository.getUserReels(
          profile.id,
          mine: profile.isMe,
          limit: _reelsLimit,
        );
        reels = reelsPage.data;
        reelsHasMore = reelsPage.data.length >= _reelsLimit;
      }
      emit(
        ProfileLoadedState(
          profile: profile,
          tab: current.tab,
          products: productsPage.data,
          reels: reels,
          reviews: current.reviews,
          productsHasMore: productsPage.data.length >= _productsLimit,
          reelsHasMore: reelsHasMore,
        ),
      );
    } catch (_) {
      // Settle the spinner but keep showing what we have.
      emit(
        current.copyWith(productsLoadingMore: false, reelsLoadingMore: false),
      );
    }
  }
}
