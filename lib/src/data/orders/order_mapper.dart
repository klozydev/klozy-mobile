import 'package:klozy/src/domain/cart/entity/cart_item.dart';
import 'package:klozy/src/domain/checkout/entity/order_fees.dart';
import 'package:klozy/src/domain/orders/entity/order.dart';
import 'package:klozy/src/domain/orders/entity/order_action.dart';
import 'package:klozy/src/domain/orders/entity/order_list_item.dart';
import 'package:klozy/src/domain/orders/entity/order_status.dart';
import 'package:klozy/src/domain/orders/entity/order_tracking.dart';
import 'package:klozy/src/domain/product/entity/product_detail.dart';

OrderRole _role(String? raw) =>
    (raw ?? '').toLowerCase() == 'seller' ? OrderRole.seller : OrderRole.buyer;

/// `GET /v1/orders` rows.
OrderListItem mapOrderListItem(Object? raw) {
  final json = raw is Map<String, dynamic> ? raw : const <String, dynamic>{};
  final role = _role(_str(json, ['viewerRole']));
  final counterpart = _party(
    json,
    role == OrderRole.buyer ? 'seller' : 'buyer',
  );
  final items = _items(json);
  final fees = _fees(json);
  return OrderListItem(
    id: _str(json, ['id', '_id']) ?? '',
    title: items.isNotEmpty ? items.first.title : '',
    coverImage: items.isNotEmpty ? items.first.image : null,
    price: fees.total > 0
        ? fees.total
        : (items.isNotEmpty ? items.first.price : 0),
    status: OrderStatus.fromApi(_str(json, ['status'])),
    counterpartName: counterpart.displayName,
    createdAt: _createdAt(_str(json, ['createdAt'])),
  );
}

/// `GET /v1/orders/{id}` detail.
Order mapOrder(Object? raw) {
  final json = raw is Map<String, dynamic> ? raw : const <String, dynamic>{};
  final role = _role(_str(json, ['viewerRole']));
  final address = json['deliveryAddress'] is Map<String, dynamic>
      ? json['deliveryAddress'] as Map<String, dynamic>
      : const <String, dynamic>{};
  return Order(
    id: _str(json, ['id', '_id']) ?? '',
    status: OrderStatus.fromApi(_str(json, ['status'])),
    viewerRole: role,
    availableActions: OrderAction.fromApi(
      json['availableActions'] is List
          ? json['availableActions'] as List<dynamic>
          : null,
    ),
    items: _items(json),
    fees: _fees(json),
    counterpart: _party(json, role == OrderRole.buyer ? 'seller' : 'buyer'),
    tracking: _tracking(json),
    deliveryName: _str(address, ['name']),
    deliveryAddress: _addressLine(address),
    returnReason: _str(json, ['returnReason']),
    createdAt: _createdAt(_str(json, ['createdAt'])),
  );
}

OrderTracking _tracking(Map<String, dynamic> json) {
  final tracking = json['tracking'] is Map<String, dynamic>
      ? json['tracking'] as Map<String, dynamic>
      : const <String, dynamic>{};
  final steps =
      (tracking['steps'] is List
              ? tracking['steps'] as List<dynamic>
              : const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(_step)
          .toList();
  return OrderTracking(
    carrier: _str(tracking, ['carrier']) ?? 'EMX',
    trackingNumber: _str(tracking, ['trackingNumber']),
    liveTrackingUrl: _str(tracking, ['liveTrackingUrl']),
    labelUrl: _str(tracking, ['labelUrl']),
    steps: steps,
  );
}

TrackingStep _step(Map<String, dynamic> json) {
  final raw = (_str(json, ['state', 'status']) ?? '').toLowerCase();
  final done = json['done'] == true || raw == 'done' || raw == 'completed';
  final active = json['active'] == true || raw == 'active' || raw == 'current';
  return TrackingStep(
    label: _str(json, ['label', 'title', 'name']) ?? '',
    sublabel: _str(json, ['sublabel', 'subtitle', 'timestamp', 'at']),
    state: done
        ? TrackStepState.done
        : (active ? TrackStepState.active : TrackStepState.pending),
  );
}

ProductSeller _party(Map<String, dynamic> json, String key) {
  final party = json[key] is Map<String, dynamic>
      ? json[key] as Map<String, dynamic>
      : const <String, dynamic>{};
  return ProductSeller(
    id: _str(party, ['id', '_id']) ?? '',
    displayName: _str(party, ['displayName', 'name']) ?? '',
    avatarUrl: _str(party, ['avatarUrl', 'avatar']),
    isPro: party['isPro'] == true || party['pro'] == true,
  );
}

List<CartItem> _items(Map<String, dynamic> json) {
  final items = json['items'];
  if (items is! List) return const <CartItem>[];
  return items.whereType<Map<String, dynamic>>().map((Map<String, dynamic> i) {
    return CartItem(
      productId: _str(i, ['productId', 'id']) ?? '',
      title: _str(i, ['title', 'name']) ?? '',
      brand: _str(i, ['brand']) ?? '',
      size: _str(i, ['size']) ?? '',
      image: _str(i, ['image', 'coverImage']),
      price: _num(i, ['price']) ?? 0,
    );
  }).toList();
}

OrderFees _fees(Map<String, dynamic> json) {
  final fees = json['fees'] is Map<String, dynamic>
      ? json['fees'] as Map<String, dynamic>
      : const <String, dynamic>{};
  return OrderFees(
    subtotal: _num(fees, ['subtotal']) ?? 0,
    shipping: _num(fees, ['shipping']) ?? 0,
    protection: _num(fees, ['protection']) ?? 0,
    vat: _num(fees, ['vat']) ?? 0,
    total: _num(fees, ['total']) ?? 0,
  );
}

String? _addressLine(Map<String, dynamic> address) {
  final parts = <String?>[
    _str(address, ['line1']),
    _str(address, ['area']),
    _str(address, ['city']),
    _str(address, ['emirate']),
  ].where((String? s) => s != null && s.isNotEmpty).toList();
  return parts.isEmpty ? null : parts.join(', ');
}

DateTime? _createdAt(String? created) {
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
