import 'package:equatable/equatable.dart';

/// A marketplace listing (feed/search/wishlist card + detail). Parsed
/// defensively — `/v1/products` is documented as an opaque object.
class Product extends Equatable {
  final String id;
  final String title;
  final String brand;
  final String size;
  final num price;
  final String? coverImageUrl;
  final String? conditionLabel;
  final int likes;
  final bool isSold;
  final bool isReserved;
  final bool isNewWithTags;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    this.brand = '',
    this.size = '',
    this.coverImageUrl,
    this.conditionLabel,
    this.likes = 0,
    this.isSold = false,
    this.isReserved = false,
    this.isNewWithTags = false,
  });

  bool get isBlocked => isSold || isReserved;

  String get meta =>
      <String>[brand, size].where((String s) => s.isNotEmpty).join(' · ');

  @override
  List<Object?> get props => [
    id,
    title,
    brand,
    size,
    price,
    coverImageUrl,
    conditionLabel,
    likes,
    isSold,
    isReserved,
    isNewWithTags,
  ];
}
