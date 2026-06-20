import 'package:equatable/equatable.dart';

enum ProductStatus { active, reserved, sold }

class ProductSeller extends Equatable {
  final String id;
  final String displayName;
  final String? avatarUrl;
  final bool isPro;
  final double rating;
  final int reviewCount;

  const ProductSeller({
    required this.id,
    this.displayName = '',
    this.avatarUrl,
    this.isPro = false,
    this.rating = 0,
    this.reviewCount = 0,
  });

  @override
  List<Object?> get props => [
    id,
    displayName,
    avatarUrl,
    isPro,
    rating,
    reviewCount,
  ];
}

/// Full listing for the product detail screen.
class ProductDetail extends Equatable {
  final String id;
  final String title;
  final num price;
  final String brand;
  final String size;
  final String? conditionLabel;
  final List<String> images;
  final String description;
  final String? location;
  final String? postedLabel;
  final int likes;
  final int views;
  final ProductStatus status;
  final ProductSeller seller;
  final bool isOwner;
  final String? categoryLabel;

  /// True when the viewer already has a pending/accepted offer with this seller
  /// — the CTA shows "See offer" instead of "Make an offer".
  final bool hasActiveOffer;

  const ProductDetail({
    required this.id,
    required this.title,
    required this.price,
    required this.seller,
    this.brand = '',
    this.size = '',
    this.conditionLabel,
    this.images = const <String>[],
    this.description = '',
    this.location,
    this.postedLabel,
    this.likes = 0,
    this.views = 0,
    this.status = ProductStatus.active,
    this.isOwner = false,
    this.categoryLabel,
    this.hasActiveOffer = false,
  });

  bool get isBlocked => status != ProductStatus.active;

  ProductDetail copyWith({
    ProductStatus? status,
    bool? isOwner,
    bool? hasActiveOffer,
  }) {
    return ProductDetail(
      id: id,
      title: title,
      price: price,
      seller: seller,
      brand: brand,
      size: size,
      conditionLabel: conditionLabel,
      images: images,
      description: description,
      location: location,
      postedLabel: postedLabel,
      likes: likes,
      views: views,
      status: status ?? this.status,
      isOwner: isOwner ?? this.isOwner,
      categoryLabel: categoryLabel,
      hasActiveOffer: hasActiveOffer ?? this.hasActiveOffer,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    price,
    brand,
    size,
    conditionLabel,
    images,
    description,
    location,
    postedLabel,
    likes,
    views,
    status,
    seller,
    isOwner,
    categoryLabel,
    hasActiveOffer,
  ];
}
