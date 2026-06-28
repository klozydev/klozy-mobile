// test/data/checkout/checkout_repository_impl_test.dart

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/data/checkout/checkout_repository_impl.dart';
import 'package:klozy/src/domain/checkout/entity/checkout_quote.dart';
import 'package:klozy/src/domain/checkout/entity/checkout_result.dart';
import 'package:mocktail/mocktail.dart';

// ── Mocks ──────────────────────────────────────────────────────────────────

class _MockDio extends Mock implements Dio {}

// ── Helpers ────────────────────────────────────────────────────────────────

Response<Map<String, dynamic>> _ok(String path, Map<String, dynamic> data) =>
    Response<Map<String, dynamic>>(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
      data: data,
    );

void main() {
  late _MockDio mockDio;
  late CheckoutRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(Options());
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    mockDio = _MockDio();
    repo = CheckoutRepositoryImpl(mockDio);
  });

  // ── checkout ─────────────────────────────────────────────────────────────

  group('checkout', () {
    test(
      'maps order summary and payment sheet from checkout response',
      () async {
        when(
          () => mockDio.post<Map<String, dynamic>>(
            'v1/checkout',
            data: any(named: 'data'),
          ),
        ).thenAnswer(
          (_) async => _ok('v1/checkout', <String, dynamic>{
            'order': <String, dynamic>{
              'id': 'ord-abc',
              '_id': 'ord-abc',
              'seller': <String, dynamic>{'displayName': 'TopSeller'},
              'items': <dynamic>[
                <String, dynamic>{
                  'productId': 'p1',
                  'title': 'White Sneakers',
                  'brand': 'Nike',
                  'size': '42',
                  'price': 200,
                },
              ],
              'fees': <String, dynamic>{
                'subtotal': 200,
                'shipping': 10,
                'protection': 5,
                'vat': 10.75,
                'total': 225.75,
              },
              'deliveryAddress': <String, dynamic>{
                'name': 'John Doe',
                'line1': '1 Main St',
                'city': 'Dubai',
                'emirate': 'Dubai',
              },
            },
            'payment': <String, dynamic>{
              'paymentIntentClientSecret': 'pi_secret',
              'ephemeralKey': 'ek_test',
              'customerId': 'cus_123',
              'publishableKey': 'pk_test',
              'amountFils': 22575,
            },
          }),
        );

        final CheckoutResult result = await repo.checkout(
          'seller1',
          addressId: 'addr1',
        );

        expect(result.order.orderId, 'ord-abc');
        expect(result.order.sellerName, 'TopSeller');
        expect(result.order.items, hasLength(1));
        expect(result.order.items.first.title, 'White Sneakers');
        expect(result.order.fees.total, 225.75);
        expect(result.order.deliveryName, 'John Doe');
        expect(result.order.deliveryAddress, contains('Dubai'));

        expect(result.payment.clientSecret, 'pi_secret');
        expect(result.payment.ephemeralKey, 'ek_test');
        expect(result.payment.customerId, 'cus_123');
        expect(result.payment.amountFils, 22575);
      },
    );

    test('includes sellerId, addressId and shipmentType in request', () async {
      when(
        () => mockDio.post<Map<String, dynamic>>(
          'v1/checkout',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => _ok('v1/checkout', <String, dynamic>{
          'order': <String, dynamic>{},
          'payment': <String, dynamic>{},
        }),
      );

      await repo.checkout(
        'seller-abc',
        addressId: 'addr-xyz',
        shipmentType: 'HAND_DELIVERY',
      );

      final VerificationResult v = verify(
        () => mockDio.post<Map<String, dynamic>>(
          'v1/checkout',
          data: captureAny(named: 'data'),
        ),
      );
      final Map<String, dynamic> body =
          v.captured.first as Map<String, dynamic>;
      expect(body['sellerId'], 'seller-abc');
      expect(body['addressId'], 'addr-xyz');
      expect(body['shipmentType'], 'HAND_DELIVERY');
    });

    test('omits optional fields when null', () async {
      when(
        () => mockDio.post<Map<String, dynamic>>(
          'v1/checkout',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => _ok('v1/checkout', <String, dynamic>{
          'order': <String, dynamic>{},
          'payment': <String, dynamic>{},
        }),
      );

      await repo.checkout('seller-abc');

      final VerificationResult v = verify(
        () => mockDio.post<Map<String, dynamic>>(
          'v1/checkout',
          data: captureAny(named: 'data'),
        ),
      );
      final Map<String, dynamic> body =
          v.captured.first as Map<String, dynamic>;
      expect(body.containsKey('addressId'), isFalse);
      expect(body.containsKey('shipmentType'), isFalse);
    });

    test('handles empty delivery address gracefully', () async {
      when(
        () => mockDio.post<Map<String, dynamic>>(
          'v1/checkout',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => _ok('v1/checkout', <String, dynamic>{
          'order': <String, dynamic>{
            'id': 'ord-2',
            'seller': <String, dynamic>{'displayName': 'S2'},
            'items': <dynamic>[],
            'fees': <String, dynamic>{},
          },
          'payment': <String, dynamic>{},
        }),
      );

      final CheckoutResult result = await repo.checkout('seller2');
      expect(result.order.deliveryAddress, isNull);
    });
  });

  // ── quote ─────────────────────────────────────────────────────────────────

  group('quote', () {
    test('maps fees from fils fields (divides by 100)', () async {
      when(
        () => mockDio.post<Map<String, dynamic>>(
          'v1/checkout/quote',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => _ok('v1/checkout/quote', <String, dynamic>{
          'addressId': 'addr1',
          'subtotalFils': 15000,
          'shippingFils': 1000,
          'protectionFils': 500,
          'vatFils': 825,
          'totalFils': 17325,
          'shipmentType': 'SHIPPING',
          'shippingOptions': <dynamic>[
            <String, dynamic>{'shipmentType': 'SHIPPING', 'amountFils': 1000},
            <String, dynamic>{'shipmentType': 'HAND_DELIVERY', 'amountFils': 0},
          ],
        }),
      );

      final CheckoutQuote result = await repo.quote(
        'seller1',
        addressId: 'addr1',
      );

      expect(result.addressId, 'addr1');
      expect(result.fees.subtotal, 150.0);
      expect(result.fees.shipping, 10.0);
      expect(result.fees.protection, 5.0);
      expect(result.fees.vat, 8.25);
      expect(result.fees.total, 173.25);
      expect(result.shipmentType, 'SHIPPING');
      expect(result.shippingOptions, hasLength(2));
      expect(result.shippingOptions.first.shipmentType, 'SHIPPING');
      expect(result.shippingOptions.first.amount, 10.0);
    });

    test('falls back to plain subtotal keys when fils keys absent', () async {
      when(
        () => mockDio.post<Map<String, dynamic>>(
          'v1/checkout/quote',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => _ok('v1/checkout/quote', <String, dynamic>{
          'subtotal': 100,
          'shipping': 0,
          'protection': 0,
          'vat': 0,
          'total': 100,
        }),
      );

      final CheckoutQuote result = await repo.quote('seller2');
      // Plain values are also divided by 100.
      expect(result.fees.subtotal, 1.0);
      expect(result.shippingOptions, isEmpty);
    });

    test('filters out shipping options with empty shipmentType', () async {
      when(
        () => mockDio.post<Map<String, dynamic>>(
          'v1/checkout/quote',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => _ok('v1/checkout/quote', <String, dynamic>{
          'shippingOptions': <dynamic>[
            <String, dynamic>{'shipmentType': '', 'amountFils': 0},
            <String, dynamic>{'shipmentType': 'SHIPPING', 'amountFils': 500},
          ],
        }),
      );

      final CheckoutQuote result = await repo.quote('seller3');
      expect(result.shippingOptions, hasLength(1));
      expect(result.shippingOptions.first.shipmentType, 'SHIPPING');
    });
  });
}
