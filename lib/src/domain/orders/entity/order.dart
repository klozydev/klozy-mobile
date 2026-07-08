import 'package:equatable/equatable.dart';
import 'package:klozy/src/domain/cart/entity/cart_item.dart';
import 'package:klozy/src/domain/checkout/entity/order_fees.dart';
import 'package:klozy/src/domain/orders/entity/order_action.dart';
import 'package:klozy/src/domain/orders/entity/order_status.dart';
import 'package:klozy/src/domain/orders/entity/order_tracking.dart';
import 'package:klozy/src/domain/product/entity/product_detail.dart';

/// Full order detail.
class Order extends Equatable {
  final String id;
  final OrderStatus status;
  final OrderRole viewerRole;
  final Set<OrderAction> availableActions;
  final List<CartItem> items;
  final OrderFees fees;
  final ProductSeller counterpart;
  final OrderTracking tracking;
  final String? deliveryName;
  final String? deliveryAddress;
  final String? returnReason;

  /// Server-provided pre-formatted label, when present. Prefer this in the UI;
  /// otherwise format [createdAt] via `RelativeTimeFormatter`.
  final String? createdAtLabel;

  /// Raw creation timestamp for locally-computed relative time. Populated by the
  /// mapper from `createdAt`; the UI localizes it via `RelativeTimeFormatter`.
  final DateTime? createdAt;

  const Order({
    required this.id,
    required this.status,
    required this.viewerRole,
    required this.counterpart,
    this.availableActions = const <OrderAction>{},
    this.items = const <CartItem>[],
    this.fees = const OrderFees(),
    this.tracking = const OrderTracking(),
    this.deliveryName,
    this.deliveryAddress,
    this.returnReason,
    this.createdAtLabel,
    this.createdAt,
  });

  /// "the seller" for a buyer's view, "the buyer" for a seller's view.
  String get counterpartRoleLabel =>
      viewerRole == OrderRole.buyer ? 'Seller' : 'Buyer';

  @override
  List<Object?> get props => [
    id,
    status,
    viewerRole,
    availableActions,
    items,
    fees,
    counterpart,
    tracking,
    deliveryName,
    deliveryAddress,
    returnReason,
    createdAtLabel,
    createdAt,
  ];
}
