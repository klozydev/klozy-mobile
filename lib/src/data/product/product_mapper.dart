import 'package:klozy/src/domain/product/entity/product.dart';

/// Defensive JSON → [Product] mapping shared by the feed and wishlist sources.
/// Field names are assumed (the API documents the payload as an opaque object).
Product mapProduct(Object? raw) {
  final json = raw is Map<String, dynamic> ? raw : const <String, dynamic>{};

  final status = (_str(json, ['status']) ?? '').toUpperCase();
  final condition = _condition(json);

  return Product(
    id: _str(json, ['id', '_id']) ?? '',
    title: _str(json, ['title', 'name']) ?? '',
    price: _num(json, ['price', 'amount']) ?? 0,
    brand: _brand(json),
    size: _str(json, ['sizeLabel', 'size']) ?? '',
    coverImageUrl: _cover(json),
    conditionLabel: condition,
    likes: (_num(json, ['likes', 'likeCount', 'likesCount']) ?? 0).toInt(),
    isSold: status == 'SOLD' || json['sold'] == true,
    isReserved: status == 'RESERVED' || json['reserved'] == true,
    isNewWithTags:
        (condition ?? '').toLowerCase().contains('new with tag') ||
        (_str(json, ['conditionId', 'conditionSlug']) ?? '')
            .toLowerCase()
            .contains('newwithtag'),
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

String? _cover(Map<String, dynamic> json) {
  final images = json['images'];
  if (images is List && images.isNotEmpty) {
    final first = images.first;
    if (first is String) return first;
    if (first is Map<String, dynamic>) return _str(first, ['url', 'src']);
  }
  return _str(json, ['coverImage', 'coverImageUrl', 'image', 'thumbnail']);
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
