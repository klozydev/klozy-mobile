import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/core/pagination/paginated_list.dart';
import 'package:klozy/src/domain/catalog/catalog_repository.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_category.dart';
import 'package:klozy/src/domain/product/entity/feed_page.dart';
import 'package:klozy/src/domain/product/entity/product.dart';
import 'package:klozy/src/domain/product/entity/search_facets.dart';
import 'package:klozy/src/domain/product/entity/search_result.dart';
import 'package:klozy/src/domain/product/products_repository.dart';
import 'package:klozy/src/feature/search/presentation/bloc/search_bloc.dart';
import 'package:klozy/src/feature/search/presentation/bloc/search_event.dart';
import 'package:klozy/src/feature/search/presentation/bloc/search_filters.dart';
import 'package:klozy/src/feature/search/presentation/bloc/search_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockProductsRepository extends Mock implements ProductsRepository {}

class _MockCatalogRepository extends Mock implements CatalogRepository {}

Future<List<SearchState>> _collectStates(
  SearchBloc bloc,
  SearchEvent event,
) async {
  final states = <SearchState>[];
  final sub = bloc.stream.listen(states.add);
  bloc.add(event);
  await Future<void>.delayed(Duration.zero);
  await sub.cancel();
  return states;
}

const _kCategory = CatalogCategory(id: 'cat1', label: 'Women');
const _kProduct = Product(id: 'p1', title: 'Shirt', price: 50.0);

const _emptyPage = PaginatedList<Product>(data: <Product>[]);
const _emptyResult = SearchResult(page: _emptyPage, facets: SearchFacets.empty);

/// 20 products — fills a full page → hasMore = true.
final _fullPage = PaginatedList<Product>(
  data: List.generate(
    20,
    (i) => Product(id: 'p$i', title: 'P$i', price: i.toDouble()),
  ),
);
final _fullResult = SearchResult(page: _fullPage, facets: SearchFacets.empty);

void main() {
  late _MockProductsRepository products;
  late _MockCatalogRepository catalog;
  late SearchBloc bloc;

  setUpAll(() {
    registerFallbackValue(ProductSort.popular);
    registerFallbackValue(<String>[]);
  });

  setUp(() {
    products = _MockProductsRepository();
    catalog = _MockCatalogRepository();

    // Sensible defaults — individual tests can override.
    when(
      () => catalog.getRootCategories(),
    ).thenAnswer((_) async => <CatalogCategory>[_kCategory]);

    when(
      () => products.feed(
        sort: any(named: 'sort'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const FeedPage(data: <Product>[_kProduct]));

    when(
      () => products.search(
        query: any(named: 'query'),
        rootCategoryId: any(named: 'rootCategoryId'),
        categoryId: any(named: 'categoryId'),
        conditions: any(named: 'conditions'),
        sizes: any(named: 'sizes'),
        brandIds: any(named: 'brandIds'),
        minPrice: any(named: 'minPrice'),
        maxPrice: any(named: 'maxPrice'),
        sort: any(named: 'sort'),
        page: any(named: 'page'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => _emptyResult);

    bloc = SearchBloc(products, catalog);
  });

  tearDown(() => bloc.close());

  // ── initial state ────────────────────────────────────────────────────────

  test('initial state is SearchLoadingState', () {
    expect(bloc.state, const SearchLoadingState());
  });

  // ── SearchInitEvent ──────────────────────────────────────────────────────

  group('SearchInitEvent', () {
    test('emits [loading, browse] on success', () async {
      final states = await _collectStates(bloc, const SearchInitEvent());

      expect(states.first, const SearchLoadingState());
      final browse = states.last as SearchBrowseState;
      expect(browse.categories, [_kCategory]);
      expect(browse.popular, [_kProduct]);
    });

    test('popular list is populated from feed()', () async {
      when(
        () => products.feed(
          sort: any(named: 'sort'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => const FeedPage(data: <Product>[_kProduct, _kProduct]),
      );

      final states = await _collectStates(bloc, const SearchInitEvent());

      final browse = states.last as SearchBrowseState;
      expect(browse.popular.length, 2);
    });

    test('emits [loading, error] when feed throws', () async {
      when(
        () => products.feed(
          sort: any(named: 'sort'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(Exception('network'));

      final states = await _collectStates(bloc, const SearchInitEvent());

      expect(states.first, const SearchLoadingState());
      expect(states.last, isA<SearchErrorState>());
    });

    test('emits [loading, error] when getRootCategories throws', () async {
      when(() => catalog.getRootCategories()).thenThrow(Exception('network'));

      final states = await _collectStates(bloc, const SearchInitEvent());

      // getRootCategories and feed share the same try block — any failure
      // emits SearchErrorState.
      expect(states.first, const SearchLoadingState());
      expect(states.last, isA<SearchErrorState>());
    });
  });

  // ── SearchQueryChanged ───────────────────────────────────────────────────

  group('SearchQueryChanged', () {
    setUp(() async {
      // Put bloc into browse state first.
      await _collectStates(bloc, const SearchInitEvent());
    });

    test('non-empty query emits [loading, results]', () async {
      when(
        () => products.search(
          query: any(named: 'query'),
          rootCategoryId: any(named: 'rootCategoryId'),
          categoryId: any(named: 'categoryId'),
          conditions: any(named: 'conditions'),
          sizes: any(named: 'sizes'),
          brandIds: any(named: 'brandIds'),
          minPrice: any(named: 'minPrice'),
          maxPrice: any(named: 'maxPrice'),
          sort: any(named: 'sort'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => const SearchResult(
          page: PaginatedList(data: <Product>[_kProduct]),
          facets: SearchFacets.empty,
        ),
      );

      final states = await _collectStates(
        bloc,
        const SearchQueryChanged('shirt'),
      );

      expect(states.first, const SearchLoadingState());
      final results = states.last as SearchResultsState;
      expect(results.query, 'shirt');
      expect(results.results, [_kProduct]);
    });

    test('empty query after entering search returns to browse', () async {
      // Enter search mode first.
      await _collectStates(bloc, const SearchQueryChanged('shirt'));

      final states = await _collectStates(bloc, const SearchQueryChanged(''));

      expect(states.whereType<SearchBrowseState>(), isNotEmpty);
      expect(states.whereType<SearchResultsState>(), isEmpty);
    });

    test('emits [loading, error] when search throws', () async {
      when(
        () => products.search(
          query: any(named: 'query'),
          rootCategoryId: any(named: 'rootCategoryId'),
          categoryId: any(named: 'categoryId'),
          conditions: any(named: 'conditions'),
          sizes: any(named: 'sizes'),
          brandIds: any(named: 'brandIds'),
          minPrice: any(named: 'minPrice'),
          maxPrice: any(named: 'maxPrice'),
          sort: any(named: 'sort'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(Exception('server'));

      final states = await _collectStates(
        bloc,
        const SearchQueryChanged('shirt'),
      );

      expect(states.first, const SearchLoadingState());
      expect(states.last, isA<SearchErrorState>());
    });

    test('whitespace-only query is treated as browse', () async {
      // Enter search first.
      await _collectStates(bloc, const SearchQueryChanged('shirt'));

      final states = await _collectStates(
        bloc,
        const SearchQueryChanged('   '),
      );

      expect(states.whereType<SearchBrowseState>(), isNotEmpty);
    });
  });

  // ── SearchFiltersChanged ─────────────────────────────────────────────────

  group('SearchFiltersChanged', () {
    setUp(() async {
      await _collectStates(bloc, const SearchInitEvent());
    });

    test('non-empty filters emits [loading, results]', () async {
      final states = await _collectStates(
        bloc,
        const SearchFiltersChanged(SearchFilters(conditions: {'new'})),
      );

      expect(states.first, const SearchLoadingState());
      expect(states.last, isA<SearchResultsState>());
    });

    test('empty filters returns to browse', () async {
      // Apply a filter first to enter results mode.
      await _collectStates(
        bloc,
        const SearchFiltersChanged(SearchFilters(conditions: {'new'})),
      );

      // Clear filters — browse should resume.
      final states = await _collectStates(
        bloc,
        const SearchFiltersChanged(SearchFilters()),
      );

      expect(states.whereType<SearchBrowseState>(), isNotEmpty);
      expect(states.whereType<SearchResultsState>(), isEmpty);
    });

    test('emits [loading, error] when search throws', () async {
      when(
        () => products.search(
          query: any(named: 'query'),
          rootCategoryId: any(named: 'rootCategoryId'),
          categoryId: any(named: 'categoryId'),
          conditions: any(named: 'conditions'),
          sizes: any(named: 'sizes'),
          brandIds: any(named: 'brandIds'),
          minPrice: any(named: 'minPrice'),
          maxPrice: any(named: 'maxPrice'),
          sort: any(named: 'sort'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(Exception('server'));

      final states = await _collectStates(
        bloc,
        const SearchFiltersChanged(SearchFilters(conditions: {'new'})),
      );

      expect(states.last, isA<SearchErrorState>());
    });
  });

  // ── SearchLoadMore ───────────────────────────────────────────────────────

  group('SearchLoadMore', () {
    /// Puts the bloc into SearchResultsState with the given [hasMore] and [page]
    /// of [count] results already loaded.
    Future<void> enterResultsState({bool hasMore = true}) async {
      await _collectStates(bloc, const SearchInitEvent());

      // Use a full page so hasMore=true.
      when(
        () => products.search(
          query: any(named: 'query'),
          rootCategoryId: any(named: 'rootCategoryId'),
          categoryId: any(named: 'categoryId'),
          conditions: any(named: 'conditions'),
          sizes: any(named: 'sizes'),
          brandIds: any(named: 'brandIds'),
          minPrice: any(named: 'minPrice'),
          maxPrice: any(named: 'maxPrice'),
          sort: any(named: 'sort'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => hasMore ? _fullResult : _emptyResult);

      await _collectStates(bloc, const SearchQueryChanged('shirt'));
    }

    test('does nothing when state is not SearchResultsState', () async {
      // State is SearchBrowseState after init.
      await _collectStates(bloc, const SearchInitEvent());

      final states = await _collectStates(bloc, const SearchLoadMore());

      expect(states, isEmpty);
    });

    test('does nothing when hasMore is false', () async {
      await enterResultsState(hasMore: false);

      final states = await _collectStates(bloc, const SearchLoadMore());

      expect(states, isEmpty);
    });

    test(
      'emits [results(loading=true), results(appended)] on success',
      () async {
        await enterResultsState();

        // Return one more product on the next page.
        when(
          () => products.search(
            query: any(named: 'query'),
            rootCategoryId: any(named: 'rootCategoryId'),
            categoryId: any(named: 'categoryId'),
            conditions: any(named: 'conditions'),
            sizes: any(named: 'sizes'),
            brandIds: any(named: 'brandIds'),
            minPrice: any(named: 'minPrice'),
            maxPrice: any(named: 'maxPrice'),
            sort: any(named: 'sort'),
            page: 2,
            limit: any(named: 'limit'),
          ),
        ).thenAnswer(
          (_) async => const SearchResult(
            page: PaginatedList(data: <Product>[_kProduct]),
            facets: SearchFacets.empty,
          ),
        );

        final states = await _collectStates(bloc, const SearchLoadMore());

        expect(states.first, isA<SearchResultsState>());
        expect((states.first as SearchResultsState).isLoadingMore, isTrue);

        final last = states.last as SearchResultsState;
        expect(last.isLoadingMore, isFalse);
        // Original 20 items + 1 new item.
        expect(last.results.length, 21);
        // 1 item returned < limit(20) → no more pages.
        expect(last.hasMore, isFalse);
      },
    );

    test(
      'emits [results(loading=true), results(loading=false)] on error',
      () async {
        await enterResultsState();

        when(
          () => products.search(
            query: any(named: 'query'),
            rootCategoryId: any(named: 'rootCategoryId'),
            categoryId: any(named: 'categoryId'),
            conditions: any(named: 'conditions'),
            sizes: any(named: 'sizes'),
            brandIds: any(named: 'brandIds'),
            minPrice: any(named: 'minPrice'),
            maxPrice: any(named: 'maxPrice'),
            sort: any(named: 'sort'),
            page: 2,
            limit: any(named: 'limit'),
          ),
        ).thenThrow(Exception('network'));

        final states = await _collectStates(bloc, const SearchLoadMore());

        expect((states.first as SearchResultsState).isLoadingMore, isTrue);
        final last = states.last as SearchResultsState;
        expect(last.isLoadingMore, isFalse);
        // Items unchanged.
        expect(last.results.length, 20);
      },
    );

    test('does nothing when isLoadingMore is already true', () async {
      // Enter results state with a full page.
      await enterResultsState();

      // Manually trigger one load-more that takes "forever".
      // We fire the event and immediately fire another — the second should
      // be ignored while the first is in flight.
      // Here we just verify that a second dispatch while loading is a no-op by
      // checking that `search` was only called twice total (once for initial
      // query, once for the first load-more).
      var callCount = 0;
      when(
        () => products.search(
          query: any(named: 'query'),
          rootCategoryId: any(named: 'rootCategoryId'),
          categoryId: any(named: 'categoryId'),
          conditions: any(named: 'conditions'),
          sizes: any(named: 'sizes'),
          brandIds: any(named: 'brandIds'),
          minPrice: any(named: 'minPrice'),
          maxPrice: any(named: 'maxPrice'),
          sort: any(named: 'sort'),
          page: 2,
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async {
        callCount++;
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return _emptyResult;
      });

      final sub = bloc.stream.listen((_) {});
      bloc.add(const SearchLoadMore()); // starts load
      bloc.add(const SearchLoadMore()); // should be ignored
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await sub.cancel();

      // search(page:2) must have been called exactly once.
      expect(callCount, 1);
    });
  });
}
