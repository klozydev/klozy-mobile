import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:event_bus/event_bus.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/core/events/products_changed_event.dart';
import 'package:klozy/src/domain/catalog/catalog_repository.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_category.dart';
import 'package:klozy/src/domain/product/entity/product.dart';
import 'package:klozy/src/domain/product/products_repository.dart';
import 'package:klozy/src/feature/home/presentation/bloc/feed_event.dart';
import 'package:klozy/src/feature/home/presentation/bloc/feed_state.dart';

@injectable
class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final ProductsRepository _productsRepository;
  final CatalogRepository _catalogRepository;

  static const int _limit = 20;
  List<CatalogCategory> _categories = const <CatalogCategory>[];
  String? _rootId;
  int _page = 1;

  late final StreamSubscription<ProductsChangedEvent> _productsChangedSub;

  FeedBloc(this._productsRepository, this._catalogRepository, EventBus eventBus)
    : super(const FeedLoading()) {
    on<FeedStarted>(_onStarted, transformer: restartable());
    // restartable: a late first-page response of the previous category must
    // not overwrite the newly selected one.
    on<FeedCategorySelected>(_onCategorySelected, transformer: restartable());
    // droppable: scroll spam queues no duplicate page fetches (the default
    // concurrent transformer would interleave them and desync _page).
    on<FeedLoadMore>(_onLoadMore, transformer: droppable());
    on<FeedRefreshed>(_onRefreshed);
    _productsChangedSub = eventBus.on<ProductsChangedEvent>().listen(
      (_) => add(const FeedRefreshed()),
    );
  }

  @override
  Future<void> close() {
    _productsChangedSub.cancel();
    return super.close();
  }

  Future<void> _onStarted(FeedStarted event, Emitter<FeedState> emit) async {
    emit(const FeedLoading());
    try {
      _categories = await _catalogRepository.getRootCategories();
    } catch (_) {
      _categories = const <CatalogCategory>[];
    }
    try {
      _page = 1;
      final page = await _productsRepository.feed(
        rootCategoryId: _rootId,
        page: _page,
        limit: _limit,
      );
      emit(
        FeedReady(
          categories: _categories,
          selectedRootId: _rootId,
          items: page.data,
          hasMore: page.data.length >= _limit,
        ),
      );
    } catch (error) {
      emit(FeedError(AppErrorType.fromException(error)));
    }
  }

  Future<void> _onCategorySelected(
    FeedCategorySelected event,
    Emitter<FeedState> emit,
  ) async {
    final current = state;
    if (current is! FeedReady) return;
    _rootId = event.rootCategoryId;
    _page = 1;
    emit(
      FeedReady(
        categories: _categories,
        selectedRootId: _rootId,
        items: const <Product>[],
        isLoadingMore: true,
      ),
    );
    try {
      final page = await _productsRepository.feed(
        rootCategoryId: _rootId,
        page: _page,
        limit: _limit,
      );
      emit(
        FeedReady(
          categories: _categories,
          selectedRootId: _rootId,
          items: page.data,
          hasMore: page.data.length >= _limit,
        ),
      );
    } catch (error) {
      emit(FeedError(AppErrorType.fromException(error)));
    }
  }

  Future<void> _onLoadMore(FeedLoadMore event, Emitter<FeedState> emit) async {
    final current = state;
    if (current is! FeedReady || current.isLoadingMore || !current.hasMore) {
      return;
    }
    final requestedRootId = _rootId;
    emit(current.copyWith(isLoadingMore: true));
    try {
      final page = await _productsRepository.feed(
        rootCategoryId: requestedRootId,
        page: _page + 1,
        limit: _limit,
      );
      // A category switch or refresh may have replaced the list while this
      // page was in flight — appending would mix categories and desync _page.
      final latest = state;
      if (emit.isDone ||
          latest is! FeedReady ||
          latest.selectedRootId != requestedRootId ||
          !latest.isLoadingMore) {
        return;
      }
      _page += 1;
      emit(
        latest.copyWith(
          items: <Product>[...latest.items, ...page.data],
          isLoadingMore: false,
          hasMore: page.data.length >= _limit,
        ),
      );
    } catch (_) {
      final latest = state;
      if (!emit.isDone && latest is FeedReady && latest.isLoadingMore) {
        emit(latest.copyWith(isLoadingMore: false));
      }
    }
  }

  /// Refetch page 1 without flashing the shimmer — the stale grid stays
  /// visible until the fresh data lands.
  Future<void> _onRefreshed(
    FeedRefreshed event,
    Emitter<FeedState> emit,
  ) async {
    try {
      if (state is! FeedReady) return;
      final requestedRootId = _rootId;
      final page = await _productsRepository.feed(
        rootCategoryId: requestedRootId,
        page: 1,
        limit: _limit,
      );
      // Drop the result if a category switch landed while refreshing.
      if (emit.isDone || _rootId != requestedRootId || state is! FeedReady) {
        return;
      }
      // Commit the page counter only on success: resetting it before the
      // request leaves a failed refresh with multi-page items but _page == 1,
      // making the next load-more append duplicates of page 2.
      _page = 1;
      emit(
        FeedReady(
          categories: _categories,
          selectedRootId: requestedRootId,
          items: page.data,
          hasMore: page.data.length >= _limit,
        ),
      );
    } catch (_) {
      // Quiet refresh: keep showing what we have.
    } finally {
      event.completer?.complete();
    }
  }
}
