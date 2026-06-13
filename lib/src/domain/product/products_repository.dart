import 'package:klozy/src/core/pagination/paginated_list.dart';
import 'package:klozy/src/domain/product/entity/create_product_input.dart';
import 'package:klozy/src/domain/product/entity/product.dart';
import 'package:klozy/src/domain/product/entity/product_detail.dart';
import 'package:klozy/src/domain/product/entity/search_result.dart';

enum ProductSort { popular, latest, priceAsc, priceDesc }

extension ProductSortApi on ProductSort {
  String get value => switch (this) {
    ProductSort.popular => 'popular',
    ProductSort.latest => 'latest',
    ProductSort.priceAsc => 'price_asc',
    ProductSort.priceDesc => 'price_desc',
  };
}

/// Read access to listings (`/v1/products`).
abstract class ProductsRepository {
  Future<PaginatedList<Product>> feed({
    String? rootCategoryId,
    String? categoryId,
    ProductSort sort = ProductSort.popular,
    int page = 1,
    int limit = 20,
  });

  /// Full-text + faceted search (`/v1/products/search`). Returns the page of
  /// products plus result-scoped [SearchResult.facets].
  Future<SearchResult> search({
    String? query,
    String? rootCategoryId,
    String? categoryId,
    ProductSort sort = ProductSort.popular,
    List<String> conditions = const <String>[],
    List<String> sizes = const <String>[],
    List<String> brandIds = const <String>[],
    num? minPrice,
    num? maxPrice,
    int page = 1,
    int limit = 20,
  });

  /// Full listing detail (`GET /v1/products/{id}`).
  Future<ProductDetail> getProduct(String id);

  /// Owner: change listing status (`PATCH /v1/products/{id}`).
  Future<void> updateStatus(String id, ProductStatus status);

  /// Owner: delete a listing (`DELETE /v1/products/{id}`).
  Future<void> deleteProduct(String id);

  /// Report a listing (`POST /v1/products/{id}/report`).
  Future<void> reportProduct(String id, String reason);

  /// Create a listing (`POST /v1/products`); returns the new product id.
  Future<String> createProduct(CreateProductInput input);

  /// Owner: edit a listing (`PATCH /v1/products/{id}`).
  Future<void> updateProduct(
    String id, {
    String? title,
    String? description,
    num? price,
    String? size,
    String? conditionId,
    String? categoryId,
    String? brandId,
    String? brandName,
  });
}
