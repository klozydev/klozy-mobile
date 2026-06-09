import 'package:klozy/src/domain/orders/entity/order.dart';
import 'package:klozy/src/domain/orders/entity/order_action.dart';
import 'package:klozy/src/domain/orders/entity/order_list_item.dart';

/// Orders (`/v1/orders`).
abstract class OrdersRepository {
  /// `GET /v1/orders?role&state` — my orders for a role/state bucket.
  Future<List<OrderListItem>> getOrders({
    required OrderRole role,
    OrderListState? state,
  });

  /// `GET /v1/orders/{id}` — full detail (tracking + available actions).
  Future<Order> getOrder(String id);

  /// `POST /v1/orders/{id}/ship` — seller: create EMX label & mark shipped.
  Future<void> ship(String id);

  /// `POST /v1/orders/{id}/confirm-receipt` — buyer: release escrow.
  Future<void> confirmReceipt(String id);

  /// `POST /v1/orders/{id}/report-problem`.
  Future<void> reportProblem(String id, String reason);

  /// `POST /v1/orders/{id}/cancel` — refund escrow (awaiting shipment).
  Future<void> cancel(String id);

  /// `POST /v1/orders/{id}/review` — buyer: 1–5 review for the seller.
  Future<void> review(String id, {required int rating, String? body});
}
