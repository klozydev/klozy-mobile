import 'dart:async';

import 'package:bloc/bloc.dart';
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
    on<FeedStarted>(_onStarted);
    on<FeedCategorySelected>(_onCategorySelected);
    on<FeedLoadMore>(_onLoadMore);
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
          pickedForYou: page.pickedForYou,
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
          pickedForYou: page.pickedForYou,
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
    emit(current.copyWith(isLoadingMore: true));
    try {
      final page = await _productsRepository.feed(
        rootCategoryId: _rootId,
        page: _page + 1,
        limit: _limit,
      );
      _page += 1;
      emit(
        current.copyWith(
          items: <Product>[...current.items, ...page.data],
          isLoadingMore: false,
          hasMore: page.data.length >= _limit,
        ),
      );
    } catch (_) {
      emit(current.copyWith(isLoadingMore: false));
    }
  }

  /// Refetch page 1 without flashing the shimmer — the stale grid stays
  /// visible until the fresh data lands.
  Future<void> _onRefreshed(
    FeedRefreshed event,
    Emitter<FeedState> emit,
  ) async {
    final current = state;
    if (current is! FeedReady) return;
    // Mark in-flight so the result is always a *distinct* state — otherwise an
    // unchanged first page is value-equal to the current state, Bloc drops the
    // emit, and the RefreshIndicator (awaiting the next state) hangs on screen.
    emit(current.copyWith(isLoadingMore: true));
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
          pickedForYou: page.pickedForYou,
          hasMore: page.data.length >= _limit,
        ),
      );
    } catch (_) {
      // Quiet refresh: keep showing what we have, but still settle the spinner.
      emit(current.copyWith(isLoadingMore: false));
    }
  }
}
