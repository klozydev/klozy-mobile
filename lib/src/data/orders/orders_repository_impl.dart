import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart' hide Order;
import 'package:klozy/src/data/orders/order_mapper.dart';
import 'package:klozy/src/domain/orders/entity/order.dart';
import 'package:klozy/src/domain/orders/entity/order_action.dart';
import 'package:klozy/src/domain/orders/entity/order_list_item.dart';
import 'package:klozy/src/domain/orders/orders_repository.dart';

@LazySingleton(as: OrdersRepository)
class OrdersRepositoryImpl implements OrdersRepository {
  final Dio _dio;

  OrdersRepositoryImpl(this._dio);

  @override
  Future<List<OrderListItem>> getOrders({
    required OrderRole role,
    OrderListState? state,
  }) async {
    final response = await _dio.get<dynamic>(
      'v1/orders',
      queryParameters: <String, dynamic>{
        'role': role == OrderRole.seller ? 'selling' : 'buying',
        if (state != null)
          'state': state == OrderListState.completed
              ? 'completed'
              : 'in_progress',
      },
    );
    return _list(response.data).map(mapOrderListItem).toList();
  }

  @override
  Future<Order> getOrder(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('v1/orders/$id');
    return mapOrder(response.data);
  }

  @override
  Future<void> ship(String id) async {
    await _dio.post<dynamic>('v1/orders/$id/ship');
  }

  @override
  Future<void> confirmReceipt(String id) async {
    await _dio.post<dynamic>('v1/orders/$id/confirm-receipt');
  }

  @override
  Future<void> reportProblem(String id, String reason) async {
    await _dio.post<dynamic>(
      'v1/orders/$id/report-problem',
      data: <String, dynamic>{'reason': reason},
    );
  }

  @override
  Future<void> cancel(String id) async {
    await _dio.post<dynamic>('v1/orders/$id/cancel');
  }

  @override
  Future<void> review(String id, {required int rating, String? body}) async {
    await _dio.post<dynamic>(
      'v1/orders/$id/review',
      data: <String, dynamic>{
        'rating': rating,
        if (body != null && body.isNotEmpty) 'body': body,
      },
    );
  }

  @override
  Future<void> acceptReturn(String id) async {
    await _dio.post<dynamic>('v1/orders/$id/accept-return');
  }

  @override
  Future<void> refuseReturn(String id, {required String reason}) async {
    await _dio.post<dynamic>(
      'v1/orders/$id/refuse-return',
      data: <String, dynamic>{'reason': reason},
    );
  }

  List<dynamic> _list(Object? data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      for (final key in const <String>['data', 'orders', 'items']) {
        if (data[key] is List) return data[key] as List<dynamic>;
      }
    }
    return const <dynamic>[];
  }
}
