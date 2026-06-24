import 'package:equatable/equatable.dart';

enum CartOfferStatus { none, pending, accepted, declined }

class CartItem extends Equatable {
  final String productId;
  final String title;
  final String brand;
  final String size;
  final String? image;

  /// List price before any offer.
  final num price;

  /// Effective price (after an accepted single-item offer, else list).
  final num effectivePrice;

  /// Single-item offer on this row (null when none or when in a bundle).
  final String? offerId;
  final num? offerAmount;
  final CartOfferStatus offerStatus;

  /// Id of the bundle offer this item belongs to (null when standalone).
  final String? bundleId;

  /// True when added to the cart after a bundle offer was made (not covered).
  final bool addedAfter;

  const CartItem({
    required this.productId,
    required this.title,
    required this.price,
    num? effectivePrice,
    this.brand = '',
    this.size = '',
    this.image,
    this.offerId,
    this.offerAmount,
    this.offerStatus = CartOfferStatus.none,
    this.bundleId,
    this.addedAfter = false,
  }) : effectivePrice = effectivePrice ?? price;

  bool get inBundle => bundleId != null;
  bool get hasItemOffer => offerId != null;
  bool get offerPending => offerStatus == CartOfferStatus.pending;
  bool get offerAccepted => offerStatus == CartOfferStatus.accepted;

  String get meta =>
      <String>[brand, size].where((String s) => s.isNotEmpty).join(' · ');

  @override
  List<Object?> get props => [
    productId,
    title,
    brand,
    size,
    image,
    price,
    effectivePrice,
    offerId,
    offerAmount,
    offerStatus,
    bundleId,
    addedAfter,
  ];
}
