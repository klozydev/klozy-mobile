import 'package:equatable/equatable.dart';
import 'package:klozy/src/domain/cart/entity/cart_item.dart';

/// One seller's items in the cart (offers + checkout happen per bucket).
class CartBucket extends Equatable {
  final String sellerId;
  final String sellerName;
  final String? sellerAvatar;
  final bool isPro;
  final List<CartItem> items;
  final num subtotal;
  final String? offerId;
  final num? offerAmount;
  final CartOfferStatus offerStatus;

  const CartBucket({
    required this.sellerId,
    required this.items,
    required this.subtotal,
    this.sellerName = '',
    this.sellerAvatar,
    this.isPro = false,
    this.offerId,
    this.offerAmount,
    this.offerStatus = CartOfferStatus.none,
  });

  bool get hasPendingOffer => offerStatus == CartOfferStatus.pending;

  @override
  List<Object?> get props => [
    sellerId,
    sellerName,
    sellerAvatar,
    isPro,
    items,
    subtotal,
    offerId,
    offerAmount,
    offerStatus,
  ];
}
