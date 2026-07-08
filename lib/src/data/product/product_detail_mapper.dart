import 'package:klozy/src/domain/product/entity/product_detail.dart';

/// Defensive JSON → [ProductDetail] mapping for `GET /v1/products/{id}`.
ProductDetail mapProductDetail(Object? raw) {
  final json = raw is Map<String, dynamic> ? raw : const <String, dynamic>{};
  final status = (_str(json, ['status']) ?? 'ACTIVE').toUpperCase();

  return ProductDetail(
    id: _str(json, ['id', '_id']) ?? '',
    title: _str(json, ['title', 'name']) ?? '',
    price: _num(json, ['price', 'amount']) ?? 0,
    brand: _brand(json),
    size: _str(json, ['sizeLabel', 'size']) ?? '',
    conditionLabel: _condition(json),
    images: _images(json),
    description: _str(json, ['description']) ?? '',
    location: _str(json, ['location']),
    postedLabel: _str(json, ['postedLabel', 'posted']),
    postedAt: _postedAt(json),
    likes: _int(json, ['likes', 'likeCount', 'likesCount']),
    views: _int(json, ['views', 'viewCount']),
    status: switch (status) {
      'SOLD' => ProductStatus.sold,
      'RESERVED' => ProductStatus.reserved,
      _ => ProductStatus.active,
    },
    seller: _seller(json),
    isOwner: json['isOwner'] == true || json['isMine'] == true,
    categoryLabel: _str(json, ['categoryLabel', 'categorySlug', 'category']),
    hasActiveOffer: json['hasActiveOffer'] == true,
  );
}

ProductSeller _seller(Map<String, dynamic> json) {
  final seller = json['seller'] is Map<String, dynamic>
      ? json['seller'] as Map<String, dynamic>
      : const <String, dynamic>{};
  return ProductSeller(
    id: _str(seller, ['id', '_id', 'uid']) ?? '',
    displayName: _str(seller, ['displayName', 'name', 'firstName']) ?? '',
    avatarUrl: _str(seller, ['avatarUrl', 'avatar', 'photoUrl']),
    isPro: seller['isPro'] == true || seller['pro'] == true,
    rating: (_num(seller, ['rating', 'avgRating']) ?? 0).toDouble(),
    reviewCount: _int(seller, ['reviewCount', 'reviews', 'ratingCount']),
  );
}

String _brand(Map<String, dynamic> json) {
  final brand = json['brand'];
  if (brand is Map<String, dynamic>) {
    return _str(brand, ['name', 'label']) ?? '';
  }
  if (brand is String) return brand;
  return _str(json, ['brandName']) ?? '';
}

/// Prefers the API-localized [conditionLabel] (falls back to English on the
/// server). `condition` stays the raw slug and is only used as a display
/// fallback when [conditionLabel] is absent, for older payload shapes.
String? _condition(Map<String, dynamic> json) {
  final String? label = _str(json, ['conditionLabel']);
  if (label != null) return label;
  final condition = json['condition'];
  if (condition is Map<String, dynamic>) {
    return _str(condition, ['label', 'name']);
  }
  if (condition is String) return condition;
  return null;
}

List<String> _images(Map<String, dynamic> json) {
  final images = json['images'];
  if (images is! List) return const <String>[];
  return images
      .map((Object? e) {
        if (e is String) return e;
        if (e is Map<String, dynamic>) return _str(e, ['url', 'src']) ?? '';
        return '';
      })
      .where((String s) => s.isNotEmpty)
      .toList();
}

DateTime? _postedAt(Map<String, dynamic> json) {
  final created = _str(json, ['createdAt', 'created']);
  if (created == null) return null;
  return DateTime.tryParse(created);
}

String? _str(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.isNotEmpty) return value;
  }
  return null;
}

num? _num(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is num) return value;
    if (value is String) {
      final parsed = num.tryParse(value);
      if (parsed != null) return parsed;
    }
  }
  return null;
}

int _int(Map<String, dynamic> json, List<String> keys) =>
    (_num(json, keys) ?? 0).toInt();
