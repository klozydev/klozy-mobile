import 'package:equatable/equatable.dart';
import 'package:klozy/src/domain/orders/entity/order_status.dart';

/// A row in the orders list.
class OrderListItem extends Equatable {
  final String id;
  final String title;
  final String? coverImage;
  final num price;
  final OrderStatus status;
  final String counterpartName;
  final String? createdAtLabel;

  const OrderListItem({
    required this.id,
    required this.title,
    required this.price,
    required this.status,
    this.coverImage,
    this.counterpartName = '',
    this.createdAtLabel,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    coverImage,
    price,
    status,
    counterpartName,
    createdAtLabel,
  ];
}
