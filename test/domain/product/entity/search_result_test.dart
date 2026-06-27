import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/core/pagination/paginated_list.dart';
import 'package:klozy/src/domain/product/entity/product.dart';
import 'package:klozy/src/domain/product/entity/search_facets.dart';
import 'package:klozy/src/domain/product/entity/search_result.dart';

void main() {
  group('SearchResult', () {
    const Product product = Product(id: 'p1', title: 'Sneakers', price: 200);
    const PaginatedList<Product> page = PaginatedList<Product>(
      data: <Product>[product],
    );
    const SearchFacets facets = SearchFacets.empty;

    const SearchResult result = SearchResult(page: page, facets: facets);

    test('getters return constructor values', () {
      expect(result.page, page);
      expect(result.facets, facets);
    });

    test('page contains the products', () {
      expect(result.page.data, <Product>[product]);
    });
  });
}
