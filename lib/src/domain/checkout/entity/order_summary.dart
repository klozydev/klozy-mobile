import 'package:equatable/equatable.dart';
import 'package:klozy/src/domain/cart/entity/cart_item.dart';
import 'package:klozy/src/domain/checkout/entity/order_fees.dart';

/// The created order shown on the checkout screen.
class OrderSummary extends Equatable {
  final String orderId;
  final String sellerName;
  final String? sellerAvatar;
  final List<CartItem> items;
  final OrderFees fees;
  final String? deliveryName;
  final String? deliveryAddress;

  const OrderSummary({
    required this.orderId,
    required this.items,
    required this.fees,
    this.sellerName = '',
    this.sellerAvatar,
    this.deliveryName,
    this.deliveryAddress,
  });

  @override
  List<Object?> get props => [
    orderId,
    sellerName,
    sellerAvatar,
    items,
    fees,
    deliveryName,
    deliveryAddress,
  ];
}
