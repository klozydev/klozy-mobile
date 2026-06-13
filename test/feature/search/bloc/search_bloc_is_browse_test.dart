import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/core/pagination/paginated_list.dart';
import 'package:klozy/src/domain/catalog/catalog_repository.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_category.dart';
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

/// Dispatches [event] to [bloc] and returns all states emitted until the
/// handler completes.
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

void main() {
  late _MockProductsRepository products;
  late _MockCatalogRepository catalog;
  late SearchBloc bloc;

  const _emptyPage = PaginatedList<Product>(data: <Product>[]);
  const _emptySearchResult = SearchResult(
    page: _emptyPage,
    facets: SearchFacets.empty,
  );
  const _emptyCategories = <CatalogCategory>[];

  setUpAll(() {
    registerFallbackValue(ProductSort.popular);
    registerFallbackValue(<String>[]);
  });

  setUp(() {
    products = _MockProductsRepository();
    catalog = _MockCatalogRepository();

    when(
      () => catalog.getRootCategories(),
    ).thenAnswer((_) async => _emptyCategories);

    when(
      () => products.feed(
        sort: any(named: 'sort'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => _emptyPage);

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
    ).thenAnswer((_) async => _emptySearchResult);

    bloc = SearchBloc(products, catalog);
  });

  tearDown(() => bloc.close());

  group('SearchBloc._isBrowse — sort condition', () {
    test(
      'non-default sort with empty query emits SearchResultsState, not SearchBrowseState',
      () async {
        // Initialise so categories/popular are loaded and bloc is in browse.
        await _collectStates(bloc, const SearchInitEvent());

        // Now switch sort to non-popular with still-empty query.
        final states = await _collectStates(
          bloc,
          const SearchSortChanged(ProductSort.priceAsc),
        );

        expect(
          states.whereType<SearchBrowseState>(),
          isEmpty,
          reason: 'non-popular sort must NOT fall back to browse state',
        );
        expect(
          states.whereType<SearchResultsState>(),
          isNotEmpty,
          reason: 'non-popular sort with empty query must trigger a search',
        );
      },
    );

    test(
      'popular sort with empty query and no filters stays in SearchBrowseState',
      () async {
        await _collectStates(bloc, const SearchInitEvent());

        // Bloc is already in SearchBrowseState after init. Re-selecting popular
        // sort (the default) keeps the browse mode. Because Equatable equality
        // suppresses a duplicate emit, we assert on bloc.state instead of the
        // emitted stream — the bloc must remain in browse, not flip to results.
        await _collectStates(
          bloc,
          const SearchSortChanged(ProductSort.popular),
        );

        expect(bloc.state, isA<SearchBrowseState>());
      },
    );

    test(
      'non-default sort then reset to popular returns to browse on empty query',
      () async {
        await _collectStates(bloc, const SearchInitEvent());
        await _collectStates(bloc, const SearchSortChanged(ProductSort.latest));

        final states = await _collectStates(
          bloc,
          const SearchSortChanged(ProductSort.popular),
        );

        expect(states.whereType<SearchBrowseState>(), isNotEmpty);
        expect(states.whereType<SearchResultsState>(), isEmpty);
      },
    );

    test(
      'non-default sort with active filter emits SearchResultsState',
      () async {
        await _collectStates(bloc, const SearchInitEvent());
        await _collectStates(
          bloc,
          const SearchFiltersChanged(SearchFilters(conditions: {'new'})),
        );

        final states = await _collectStates(
          bloc,
          const SearchSortChanged(ProductSort.priceDesc),
        );

        expect(states.whereType<SearchResultsState>(), isNotEmpty);
        expect(states.whereType<SearchBrowseState>(), isEmpty);
      },
    );
  });
}
