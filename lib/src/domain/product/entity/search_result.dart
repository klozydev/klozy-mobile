import 'package:klozy/src/core/pagination/paginated_list.dart';
import 'package:klozy/src/domain/product/entity/product.dart';
import 'package:klozy/src/domain/product/entity/search_facets.dart';

/// A page of search results plus the result-scoped facets returned alongside
/// them by `/v1/products/search`.
class SearchResult {
  final PaginatedList<Product> page;
  final SearchFacets facets;

  const SearchResult({required this.page, required this.facets});
}
