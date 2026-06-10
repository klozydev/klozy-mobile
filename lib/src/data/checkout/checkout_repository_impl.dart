import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/domain/cart/entity/cart_item.dart';
import 'package:klozy/src/domain/checkout/checkout_repository.dart';
import 'package:klozy/src/domain/checkout/entity/checkout_quote.dart';
import 'package:klozy/src/domain/checkout/entity/checkout_result.dart';
import 'package:klozy/src/domain/checkout/entity/order_fees.dart';
import 'package:klozy/src/domain/checkout/entity/order_summary.dart';
import 'package:klozy/src/domain/checkout/entity/payment_sheet_data.dart';

@LazySingleton(as: CheckoutRepository)
class CheckoutRepositoryImpl implements CheckoutRepository {
  final Dio _dio;

  CheckoutRepositoryImpl(this._dio);

  @override
  Future<CheckoutResult> checkout(
    String sellerId, {
    String? addressId,
    String? shipmentType,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'v1/checkout',
      data: <String, dynamic>{
        'sellerId': sellerId,
        if (addressId != null) 'addressId': addressId,
        if (shipmentType != null) 'shipmentType': shipmentType,
      },
    );
    final json = response.data ?? const <String, dynamic>{};
    final order = _map(json, 'order');
    final payment = _map(json, 'payment');
    return CheckoutResult(
      order: _orderSummary(order),
      payment: _payment(payment),
    );
  }

  @override
  Future<CheckoutQuote> quote(String sellerId, {String? addressId}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'v1/checkout/quote',
      data: <String, dynamic>{
        'sellerId': sellerId,
        if (addressId != null) 'addressId': addressId,
      },
    );
    final json = response.data ?? const <String, dynamic>{};
    // Fees come back in fils (1 AED = 100 fils).
    num aed(List<String> keys) => (_num(json, keys) ?? 0) / 100;
    final rawOptions = json['shippingOptions'] is List
        ? json['shippingOptions'] as List<dynamic>
        : const <dynamic>[];
    return CheckoutQuote(
      addressId: _str(json, ['addressId']) ?? addressId,
      fees: OrderFees(
        subtotal: aed(['subtotalFils', 'subtotal']),
        shipping: aed(['shippingFils', 'shipping']),
        protection: aed(['protectionFils', 'protection']),
        vat: aed(['vatFils', 'vat']),
        total: aed(['totalFils', 'total']),
      ),
      shipmentType: _str(json, ['shipmentType']),
      shippingOptions: rawOptions
          .whereType<Map<String, dynamic>>()
          .map(
            (Map<String, dynamic> o) => ShippingOption(
              shipmentType: _str(o, ['shipmentType']) ?? '',
              amount: (_num(o, ['amountFils']) ?? 0) / 100,
            ),
          )
          .where((ShippingOption o) => o.shipmentType.isNotEmpty)
          .toList(),
    );
  }

  Map<String, dynamic> _map(Map<String, dynamic> json, String key) {
    final value = json[key];
    return value is Map<String, dynamic> ? value : const <String, dynamic>{};
  }

  OrderSummary _orderSummary(Map<String, dynamic> order) {
    final seller = _map(order, 'seller');
    final address = _map(order, 'deliveryAddress');
    final fees = _map(order, 'fees');
    final items =
        (order['items'] is List
                ? order['items'] as List<dynamic>
                : const <dynamic>[])
            .whereType<Map<String, dynamic>>()
            .map(_item)
            .toList();
    return OrderSummary(
      orderId: _str(order, ['id', '_id']) ?? '',
      sellerName: _str(seller, ['displayName', 'name', 'handle']) ?? '',
      sellerAvatar: _str(seller, ['avatarUrl', 'avatar']),
      items: items,
      fees: OrderFees(
        subtotal: _num(fees, ['subtotal']) ?? 0,
        shipping: _num(fees, ['shipping']) ?? 0,
        protection: _num(fees, ['protection']) ?? 0,
        vat: _num(fees, ['vat']) ?? 0,
        total: _num(fees, ['total']) ?? 0,
      ),
      deliveryName: _str(address, ['name']),
      deliveryAddress: _addressLine(address),
    );
  }

  CartItem _item(Map<String, dynamic> json) {
    return CartItem(
      productId: _str(json, ['productId', 'id']) ?? '',
      title: _str(json, ['title', 'name']) ?? '',
      brand: _str(json, ['brand']) ?? '',
      size: _str(json, ['size']) ?? '',
      image: _str(json, ['image', 'coverImage']),
      price: _num(json, ['price']) ?? 0,
    );
  }

  PaymentSheetData _payment(Map<String, dynamic> payment) {
    return PaymentSheetData(
      clientSecret:
          _str(payment, ['paymentIntentClientSecret', 'clientSecret']) ?? '',
      ephemeralKey: _str(payment, ['ephemeralKey']) ?? '',
      customerId: _str(payment, ['customerId']) ?? '',
      publishableKey: _str(payment, ['publishableKey']) ?? '',
      amountFils: _num(payment, ['amountFils', 'amount']) ?? 0,
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
}
