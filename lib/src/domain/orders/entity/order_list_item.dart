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

  /// Server-provided pre-formatted label, when present. Prefer this in the UI;
  /// otherwise format [createdAt] via `RelativeTimeFormatter`.
  final String? createdAtLabel;

  /// Raw creation timestamp for locally-computed relative time. Populated by the
  /// mapper from `createdAt`; the UI localizes it via `RelativeTimeFormatter`.
  final DateTime? createdAt;

  const OrderListItem({
    required this.id,
    required this.title,
    required this.price,
    required this.status,
    this.coverImage,
    this.counterpartName = '',
    this.createdAtLabel,
    this.createdAt,
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
    createdAt,
  ];
}
