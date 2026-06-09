import 'package:equatable/equatable.dart';

enum CartOfferStatus { none, pending, accepted, declined }

class CartItem extends Equatable {
  final String productId;
  final String title;
  final String brand;
  final String size;
  final String? image;
  final num price;
  final num? offerPrice;
  final CartOfferStatus offerStatus;

  const CartItem({
    required this.productId,
    required this.title,
    required this.price,
    this.brand = '',
    this.size = '',
    this.image,
    this.offerPrice,
    this.offerStatus = CartOfferStatus.none,
  });

  num get effectivePrice =>
      offerStatus == CartOfferStatus.accepted && offerPrice != null
      ? offerPrice!
      : price;

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
    offerPrice,
    offerStatus,
  ];
}
