import 'package:dio/dio.dart';
import 'package:event_bus/event_bus.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/core/events/products_changed_event.dart';
import 'package:klozy/src/core/pagination/paginated_list.dart';
import 'package:klozy/src/core/pagination/paginated_list_response.dart';
import 'package:klozy/src/data/product/product_detail_mapper.dart';
import 'package:klozy/src/data/product/product_mapper.dart';
import 'package:klozy/src/domain/product/entity/create_product_input.dart';
import 'package:klozy/src/domain/product/entity/product.dart';
import 'package:klozy/src/domain/product/entity/product_detail.dart';
import 'package:klozy/src/domain/product/products_repository.dart';

@LazySingleton(as: ProductsRepository)
class ProductsRepositoryImpl implements ProductsRepository {
  final Dio _dio;
  final EventBus _eventBus;

  ProductsRepositoryImpl(this._dio, this._eventBus);

  @override
  Future<PaginatedList<Product>> feed({
    String? rootCategoryId,
    String? categoryId,
    ProductSort sort = ProductSort.popular,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'v1/products',
      queryParameters: <String, dynamic>{
        if (rootCategoryId != null) 'rootCategoryId': rootCategoryId,
        if (categoryId != null) 'categoryId': categoryId,
        'sort': sort.value,
        'page': page,
        'limit': limit,
      },
    );
    final parsed = PaginatedListResponse<Product>.fromJson(
      response.data ?? const <String, dynamic>{},
      mapProduct,
    );
    return PaginatedList<Product>(data: parsed.data, metadata: parsed.metadata);
  }

  @override
  Future<PaginatedList<Product>> search({
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
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'v1/products/search',
      queryParameters: <String, dynamic>{
        if (query != null && query.isNotEmpty) 'q': query,
        if (rootCategoryId != null) 'rootCategoryId': rootCategoryId,
        if (categoryId != null) 'categoryId': categoryId,
        if (conditions.isNotEmpty) 'conditions': conditions.join(','),
        if (sizes.isNotEmpty) 'sizes': sizes.join(','),
        if (brandIds.isNotEmpty) 'brandIds': brandIds.join(','),
        if (minPrice != null) 'minPrice': minPrice,
        if (maxPrice != null) 'maxPrice': maxPrice,
        'sort': sort.value,
        'page': page,
        'limit': limit,
      },
    );
    final parsed = PaginatedListResponse<Product>.fromJson(
      response.data ?? const <String, dynamic>{},
      mapProduct,
    );
    return PaginatedList<Product>(data: parsed.data, metadata: parsed.metadata);
  }

  @override
  Future<ProductDetail> getProduct(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('v1/products/$id');
    return mapProductDetail(response.data);
  }

  @override
  Future<void> updateStatus(String id, ProductStatus status) async {
    await _dio.patch<dynamic>(
      'v1/products/$id',
      data: <String, dynamic>{'status': status.name.toUpperCase()},
    );
    _eventBus.fire(const ProductsChangedEvent());
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _dio.delete<dynamic>('v1/products/$id');
    _eventBus.fire(const ProductsChangedEvent());
  }

  @override
  Future<void> reportProduct(String id, String reason) async {
    await _dio.post<dynamic>(
      'v1/products/$id/report',
      data: <String, dynamic>{'reason': reason},
    );
  }

  @override
  Future<String> createProduct(CreateProductInput input) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'v1/products',
      data: input.toJson(),
    );
    final json = response.data ?? const <String, dynamic>{};
    final inner = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    final id = inner['id'] ?? inner['_id'];
    _eventBus.fire(const ProductsChangedEvent());
    return id is String ? id : '';
  }

  @override
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
  }) async {
    await _dio.patch<dynamic>(
      'v1/products/$id',
      data: <String, dynamic>{
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (price != null) 'price': price,
        if (size != null && size.isNotEmpty) 'size': size,
        if (conditionId != null && conditionId.isNotEmpty)
          'conditionId': conditionId,
        if (categoryId != null && categoryId.isNotEmpty)
          'categoryId': categoryId,
        if (brandId != null && brandId.isNotEmpty) 'brandId': brandId,
        if (brandName != null && brandName.isNotEmpty) 'brandName': brandName,
      },
    );
    _eventBus.fire(const ProductsChangedEvent());
  }
}
