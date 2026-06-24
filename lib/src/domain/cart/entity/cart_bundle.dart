import 'package:equatable/equatable.dart';
import 'package:klozy/src/domain/cart/entity/cart_item.dart';

/// A multi-item ("offer for all") offer covering a snapshot of a seller's items.
class CartBundle extends Equatable {
  final String id;
  final num amount;
  final CartOfferStatus status;
  final List<String> productIds;

  /// Sum of the covered items' list prices.
  final num listSum;

  const CartBundle({
    required this.id,
    required this.amount,
    required this.status,
    required this.productIds,
    required this.listSum,
  });

  int get itemCount => productIds.length;
  bool get accepted => status == CartOfferStatus.accepted;

  @override
  List<Object?> get props => [id, amount, status, productIds, listSum];
}
