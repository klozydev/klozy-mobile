import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:event_bus/event_bus.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/core/events/products_changed_event.dart';
import 'package:klozy/src/core/events/profile_changed_event.dart';
import 'package:klozy/src/core/events/reels_changed_event.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
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

  ProfileBloc(this._repository, this._meRepository, EventBus eventBus)
    : super(const ProfileLoadingState()) {
    on<ProfileStarted>(_onStarted);
    on<ProfileTabChanged>(_onTabChanged);
    on<ProfileFollowToggled>(_onFollowToggled);
    on<ProfileReported>(_onReported);
    on<ProfileBlocked>(_onBlocked);
    on<ProfileRefreshed>(_onRefreshed);
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
      List<dynamic> products;
      try {
        products = await _repository.getUserProducts(profile.id);
      } catch (_) {
        products = const <dynamic>[];
      }
      emit(ProfileLoadedState(profile: profile, products: products.cast()));
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
        final reels = await _repository.getUserReels(
          current.profile.id,
          mine: current.profile.isMe,
        );
        emit(
          (state as ProfileLoadedState).copyWith(
            reels: reels,
            tabLoading: false,
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
      final products = await _repository.getUserProducts(profile.id);
      final reels = current.reels == null
          ? null
          : await _repository.getUserReels(profile.id, mine: true);
      final latest = state;
      if (latest is! ProfileLoadedState) return;
      emit(
        latest.copyWith(
          profile: profile,
          products: products,
          reels: reels ?? latest.reels,
        ),
      );
    } catch (_) {
      // Quiet refresh: keep showing what we have.
    }
  }
}
