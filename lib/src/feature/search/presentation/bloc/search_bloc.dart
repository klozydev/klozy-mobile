import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/domain/catalog/catalog_repository.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_category.dart';
import 'package:klozy/src/domain/product/entity/product.dart';
import 'package:klozy/src/domain/product/products_repository.dart';
import 'package:klozy/src/feature/search/presentation/bloc/search_event.dart';
import 'package:klozy/src/feature/search/presentation/bloc/search_filters.dart';
import 'package:klozy/src/feature/search/presentation/bloc/search_state.dart';

@injectable
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final ProductsRepository _productsRepository;
  final CatalogRepository _catalogRepository;

  static const int _limit = 20;
  String _query = '';
  ProductSort _sort = ProductSort.popular;
  SearchFilters _filters = const SearchFilters();
  int _page = 1;
  List<CatalogCategory> _categories = const <CatalogCategory>[];
  List<Product> _popular = const <Product>[];

  SearchBloc(this._productsRepository, this._catalogRepository)
    : super(const SearchLoadingState()) {
    on<SearchInitEvent>(_onInit);
    on<SearchQueryChanged>(_onQueryChanged);
    on<SearchSortChanged>(_onSortChanged);
    on<SearchFiltersChanged>(_onFiltersChanged);
    on<SearchLoadMore>(_onLoadMore);
  }

  bool get _isBrowse => _query.trim().isEmpty && _filters.isEmpty;

  Future<void> _onInit(SearchInitEvent event, Emitter<SearchState> emit) async {
    emit(const SearchLoadingState());
    try {
      _categories = await _catalogRepository.getRootCategories();
      _popular = (await _productsRepository.feed(
        sort: ProductSort.popular,
        limit: 4,
      )).data;
      emit(SearchBrowseState(categories: _categories, popular: _popular));
    } catch (error) {
      emit(SearchErrorState(type: AppErrorType.fromException(error)));
    }
  }

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) {
    _query = event.query;
    return _decide(emit);
  }

  Future<void> _onSortChanged(
    SearchSortChanged event,
    Emitter<SearchState> emit,
  ) {
    _sort = event.sort;
    return _decide(emit);
  }

  Future<void> _onFiltersChanged(
    SearchFiltersChanged event,
    Emitter<SearchState> emit,
  ) {
    _filters = event.filters;
    return _decide(emit);
  }

  Future<void> _decide(Emitter<SearchState> emit) async {
    if (_isBrowse) {
      emit(SearchBrowseState(categories: _categories, popular: _popular));
      return;
    }
    emit(const SearchLoadingState());
    try {
      _page = 1;
      final page = await _search(_page);
      emit(
        SearchResultsState(
          results: page,
          query: _query,
          sort: _sort,
          filters: _filters,
          hasMore: page.length >= _limit,
        ),
      );
    } catch (error) {
      emit(SearchErrorState(type: AppErrorType.fromException(error)));
    }
  }

  Future<void> _onLoadMore(
    SearchLoadMore event,
    Emitter<SearchState> emit,
  ) async {
    final current = state;
    if (current is! SearchResultsState ||
        current.isLoadingMore ||
        !current.hasMore) {
      return;
    }
    emit(current.copyWith(isLoadingMore: true));
    try {
      final page = await _search(_page + 1);
      _page += 1;
      emit(
        current.copyWith(
          results: <Product>[...current.results, ...page],
          isLoadingMore: false,
          hasMore: page.length >= _limit,
        ),
      );
    } catch (_) {
      emit(current.copyWith(isLoadingMore: false));
    }
  }

  Future<List<Product>> _search(int page) async {
    final result = await _productsRepository.search(
      query: _query.trim().isEmpty ? null : _query.trim(),
      rootCategoryId: _filters.rootCategoryId,
      categoryId: _filters.categoryId,
      conditions: _filters.conditions.toList(),
      sizes: _filters.sizes.toList(),
      sort: _sort,
      page: page,
      limit: _limit,
    );
    return result.data;
  }
}
