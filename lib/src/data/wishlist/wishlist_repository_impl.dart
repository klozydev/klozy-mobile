import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/core/pagination/paginated_list.dart';
import 'package:klozy/src/core/pagination/paginated_list_response.dart';
import 'package:klozy/src/data/product/product_mapper.dart';
import 'package:klozy/src/domain/product/entity/product.dart';
import 'package:klozy/src/domain/wishlist/wishlist_repository.dart';

@LazySingleton(as: WishlistRepository)
class WishlistRepositoryImpl implements WishlistRepository {
  final Dio _dio;

  WishlistRepositoryImpl(this._dio);

  @override
  Future<Set<String>> getWishlistProductIds() async {
    // First page only seeds the set (good enough for the global toggle state).
    final page = await getWishlistProducts(limit: 50);
    return page.data
        .map((Product p) => p.id)
        .where((s) => s.isNotEmpty)
        .toSet();
  }

  @override
  Future<PaginatedList<Product>> getWishlistProducts({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'v1/me/wishlist',
      queryParameters: <String, dynamic>{'page': page, 'limit': limit},
    );
    final parsed = PaginatedListResponse<Product>.fromJson(
      response.data ?? const <String, dynamic>{},
      mapProduct,
    );
    return PaginatedList<Product>(data: parsed.data, metadata: parsed.metadata);
  }

  @override
  Future<void> add(String productId) async {
    await _dio.put<dynamic>('v1/me/wishlist/$productId');
  }

  @override
  Future<void> remove(String productId) async {
    await _dio.delete<dynamic>('v1/me/wishlist/$productId');
  }
}
