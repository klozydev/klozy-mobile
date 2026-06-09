import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/data/cart/cart_mapper.dart';
import 'package:klozy/src/domain/cart/cart_repository.dart';
import 'package:klozy/src/domain/cart/entity/cart.dart';

@LazySingleton(as: CartRepository)
class CartRepositoryImpl implements CartRepository {
  final Dio _dio;

  CartRepositoryImpl(this._dio);

  @override
  Future<Cart> getCart() async {
    final response = await _dio.get<Map<String, dynamic>>('v1/cart');
    return mapCart(response.data);
  }

  @override
  Future<void> addItem(String productId) async {
    await _dio.post<dynamic>(
      'v1/cart/items',
      data: <String, dynamic>{'productId': productId},
    );
  }

  @override
  Future<void> removeItem(String productId) async {
    await _dio.delete<dynamic>('v1/cart/items/$productId');
  }
}
