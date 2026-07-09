import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:event_bus/event_bus.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/core/events/wishlist_changed_event.dart';
import 'package:klozy/src/domain/product/entity/product.dart';
import 'package:klozy/src/domain/wishlist/wishlist_repository.dart';
import 'package:klozy/src/feature/home/presentation/bloc/wishlist_feed_state.dart';

/// Paginated holder for the Wishlist tab. Fetches pages from
/// [WishlistRepository] and subscribes to [WishlistChangedEvent] to reload
/// quietly when the user (un)wishes a product elsewhere. The UI still filters
/// the emitted items against the global `WishlistCubit` id-set.
@injectable
class WishlistFeedCubit extends Cubit<WishlistFeedState> {
  final WishlistRepository _repository;

  static const int _limit = 20;
  int _page = 1;

  late final StreamSubscription<WishlistChangedEvent> _wishlistChangedSub;

  WishlistFeedCubit(this._repository, EventBus eventBus)
    : super(const WishlistFeedLoading()) {
    _wishlistChangedSub = eventBus.on<WishlistChangedEvent>().listen((_) {
      refresh();
    });
  }

  /// Fetch the first page. Reset `_page` to 1, emit [WishlistFeedLoading], then
  /// [WishlistFeedLoaded] with `hasMore = page.data.length >= _limit`, or
  /// [WishlistFeedError] on failure.
  Future<void> load() async {
    emit(const WishlistFeedLoading());
    try {
      _page = 1;
      final page = await _repository.getWishlistProducts(
        page: _page,
        limit: _limit,
      );
      emit(
        WishlistFeedLoaded(
          items: page.data,
          hasMore: page.data.length >= _limit,
        ),
      );
    } catch (error) {
      emit(WishlistFeedError(AppErrorType.fromException(error)));
    }
  }

  /// Append the next page. Guard on `loadingMore`/`hasMore`, flip `loadingMore`
  /// true, fetch page `_page + 1` (limit `_limit`), increment `_page` on
  /// success, then emit appended items. Mirror FeedBloc._onLoadMore.
  Future<void> loadMore() async {
    final current = state;
    if (current is! WishlistFeedLoaded ||
        current.loadingMore ||
        !current.hasMore) {
      return;
    }
    emit(current.copyWith(loadingMore: true));
    try {
      final page = await _repository.getWishlistProducts(
        page: _page + 1,
        limit: _limit,
      );
      _page += 1;
      emit(
        current.copyWith(
          items: <Product>[...current.items, ...page.data],
          loadingMore: false,
          hasMore: page.data.length >= _limit,
        ),
      );
    } catch (_) {
      emit(current.copyWith(loadingMore: false));
    }
  }

  /// User pull-to-refresh: reset `_page` to 1 and refetch the first page. Emit
  /// a value-distinct state FIRST (e.g. flip `loadingMore` true) so the
  /// RefreshIndicator does not hang on an equal emit. Mirror
  /// FeedBloc._onRefreshed.
  Future<void> refresh() async {
    final current = state;
    if (current is! WishlistFeedLoaded) {
      await load();
      return;
    }
    emit(current.copyWith(loadingMore: true));
    try {
      _page = 1;
      final page = await _repository.getWishlistProducts(
        page: _page,
        limit: _limit,
      );
      emit(
        WishlistFeedLoaded(
          items: page.data,
          hasMore: page.data.length >= _limit,
        ),
      );
    } catch (_) {
      // Quiet refresh: keep showing what we have, but still settle the
      // spinner.
      emit(current.copyWith(loadingMore: false));
    }
  }

  @override
  Future<void> close() {
    _wishlistChangedSub.cancel();
    return super.close();
  }
}
