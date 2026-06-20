import 'package:klozy/src/domain/cart/entity/cart.dart';
import 'package:klozy/src/domain/cart/entity/cart_bucket.dart';
import 'package:klozy/src/domain/cart/entity/cart_item.dart';

/// Defensive JSON → [Cart] mapping (`GET /v1/cart` is an opaque object).
Cart mapCart(Object? raw) {
  final json = raw is Map<String, dynamic> ? raw : const <String, dynamic>{};
  final inner = json['data'] is Map<String, dynamic>
      ? json['data'] as Map<String, dynamic>
      : json;
  final rawBuckets = inner['buckets'] ?? inner['sellers'] ?? inner['items'];
  if (rawBuckets is! List) return Cart.empty;
  return Cart(
    buckets: rawBuckets
        .whereType<Map<String, dynamic>>()
        .map(_bucket)
        .where((CartBucket b) => b.items.isNotEmpty)
        .toList(),
  );
}

CartBucket _bucket(Map<String, dynamic> json) {
  final seller = json['seller'] is Map<String, dynamic>
      ? json['seller'] as Map<String, dynamic>
      : const <String, dynamic>{};
  final offer = json['offer'] is Map<String, dynamic>
      ? json['offer'] as Map<String, dynamic>
      : const <String, dynamic>{};
  final items =
      (json['items'] is List ? json['items'] as List<dynamic> : const [])
          .whereType<Map<String, dynamic>>()
          .map(_item)
          .toList();
  final status = _offerStatus(_str(offer, ['status']));
  return CartBucket(
    sellerId: _str(seller, ['id', '_id']) ?? _str(json, ['sellerId']) ?? '',
    sellerName: _str(seller, ['displayName', 'name']) ?? '',
    sellerAvatar: _str(seller, ['avatarUrl', 'avatar', 'photoUrl']),
    isPro: seller['isPro'] == true || seller['pro'] == true,
    items: items,
    subtotal:
        _num(json, ['subtotal', 'total']) ??
        items.fold<num>(0, (num s, CartItem i) => s + i.effectivePrice),
    offerId: _str(offer, ['id', '_id']),
    offerAmount: _num(offer, ['amount']),
    offerStatus: status,
  );
}

CartItem _item(Map<String, dynamic> json) {
  final product = json['product'] is Map<String, dynamic>
      ? json['product'] as Map<String, dynamic>
      : json;
  return CartItem(
    productId: _str(product, ['id', '_id']) ?? _str(json, ['productId']) ?? '',
    title: _str(product, ['title', 'name']) ?? '',
    brand: _brand(product),
    size: _str(product, ['size']) ?? '',
    image: _cover(product),
    price: _num(product, ['price']) ?? _num(json, ['price']) ?? 0,
    offerPrice: _num(json, ['offer', 'offerPrice']),
    offerStatus: _offerStatus(_str(json, ['offerStatus'])),
  );
}

CartOfferStatus _offerStatus(String? raw) {
  switch (raw?.toLowerCase()) {
    case 'pending':
      return CartOfferStatus.pending;
    case 'accepted':
      return CartOfferStatus.accepted;
    case 'declined':
    case 'refused':
      return CartOfferStatus.declined;
    default:
      return CartOfferStatus.none;
  }
}

String _brand(Map<String, dynamic> json) {
  final brand = json['brand'];
  if (brand is Map<String, dynamic>) {
    return _str(brand, ['name', 'label']) ?? '';
  }
  if (brand is String) return brand;
  return _str(json, ['brandName']) ?? '';
}

String? _cover(Map<String, dynamic> json) {
  final images = json['images'];
  if (images is List && images.isNotEmpty) {
    final first = images.first;
    if (first is String) return first;
    if (first is Map<String, dynamic>) return _str(first, ['url', 'src']);
  }
  return _str(json, ['image', 'coverImage', 'thumbnail']);
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
