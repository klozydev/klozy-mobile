import 'package:klozy/src/domain/cart/entity/cart.dart';
import 'package:klozy/src/domain/cart/entity/cart_bucket.dart';
import 'package:klozy/src/domain/cart/entity/cart_bundle.dart';
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
  final items =
      (json['items'] is List ? json['items'] as List<dynamic> : const [])
          .whereType<Map<String, dynamic>>()
          .map(_item)
          .toList();
  final bundles =
      (json['bundles'] is List ? json['bundles'] as List<dynamic> : const [])
          .whereType<Map<String, dynamic>>()
          .map(_bundle)
          .toList();
  return CartBucket(
    sellerId: _str(seller, ['id', '_id']) ?? _str(json, ['sellerId']) ?? '',
    sellerName: _str(seller, ['displayName', 'name']) ?? '',
    sellerAvatar: _str(seller, ['avatarUrl', 'avatar', 'photoUrl']),
    isPro: seller['isPro'] == true || seller['pro'] == true,
    items: items,
    subtotal:
        _num(json, ['subtotal', 'total']) ??
        items.fold<num>(0, (num s, CartItem i) => s + i.effectivePrice),
    bundles: bundles,
    canBundle: json['canBundle'] == true,
  );
}

CartBundle _bundle(Map<String, dynamic> json) {
  final ids = json['productIds'];
  return CartBundle(
    id: _str(json, ['id', '_id']) ?? '',
    amount: _num(json, ['amount', 'amountFils']) ?? 0,
    status: _offerStatus(_str(json, ['status'])),
    productIds: ids is List
        ? ids.whereType<String>().toList()
        : const <String>[],
    listSum: _num(json, ['listSum']) ?? 0,
  );
}

CartItem _item(Map<String, dynamic> json) {
  final product = json['product'] is Map<String, dynamic>
      ? json['product'] as Map<String, dynamic>
      : json;
  final price = _num(json, ['listPrice']) ?? _num(product, ['price']) ?? 0;
  return CartItem(
    productId: _str(json, ['productId']) ?? _str(product, ['id', '_id']) ?? '',
    title: _str(product, ['title', 'name']) ?? '',
    brand: _brand(product),
    size: _str(product, ['size']) ?? '',
    image: _cover(product),
    price: price,
    effectivePrice: _num(json, ['effectivePrice']) ?? price,
    offerId: _str(json, ['offerId']),
    offerAmount: _num(json, ['offerAmount']),
    offerStatus: _offerStatus(_str(json, ['offerStatus'])),
    bundleId: _str(json, ['bundleId']),
    addedAfter: json['addedAfter'] == true,
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
