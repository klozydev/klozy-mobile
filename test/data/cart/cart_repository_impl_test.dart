// test/data/cart/cart_repository_impl_test.dart

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/data/cart/cart_repository_impl.dart';
import 'package:klozy/src/domain/cart/entity/cart.dart';
import 'package:mocktail/mocktail.dart';

// ── Mocks ──────────────────────────────────────────────────────────────────

class _MockDio extends Mock implements Dio {}

// ── Helpers ────────────────────────────────────────────────────────────────

Response<T> _ok<T>(String path, T data) => Response<T>(
  requestOptions: RequestOptions(path: path),
  statusCode: 200,
  data: data,
);

Response<dynamic> _voidOk(String path) => Response<dynamic>(
  requestOptions: RequestOptions(path: path),
  statusCode: 200,
);

/// Minimal cart response with one seller bucket and one item.
Map<String, dynamic> _cartJson() => <String, dynamic>{
  'buckets': <dynamic>[
    <String, dynamic>{
      'sellerId': 's1',
      'seller': <String, dynamic>{'id': 's1', 'displayName': 'Seller One'},
      'items': <dynamic>[
        <String, dynamic>{
          'productId': 'p1',
          'product': <String, dynamic>{
            'id': 'p1',
            'title': 'Blue Jeans',
            'price': 80,
            'brand': "Levi's",
            'size': '32',
          },
          'listPrice': 80,
        },
      ],
    },
  ],
};

void main() {
  late _MockDio mockDio;
  late CartRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(Options());
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    mockDio = _MockDio();
    repo = CartRepositoryImpl(mockDio);
  });

  // ── getCart ──────────────────────────────────────────────────────────────

  group('getCart', () {
    test('maps buckets from GET /v1/cart', () async {
      when(() => mockDio.get<Map<String, dynamic>>('v1/cart')).thenAnswer(
        (_) async => _ok<Map<String, dynamic>>('v1/cart', _cartJson()),
      );

      final Cart result = await repo.getCart();

      expect(result.buckets, hasLength(1));
      expect(result.buckets.first.sellerId, 's1');
      expect(result.buckets.first.sellerName, 'Seller One');
      expect(result.buckets.first.items, hasLength(1));
      expect(result.buckets.first.items.first.productId, 'p1');
      expect(result.buckets.first.items.first.title, 'Blue Jeans');
    });

    test('returns empty cart when data is empty', () async {
      when(() => mockDio.get<Map<String, dynamic>>('v1/cart')).thenAnswer(
        (_) async => _ok<Map<String, dynamic>>('v1/cart', <String, dynamic>{}),
      );

      final Cart result = await repo.getCart();
      expect(result.buckets, isEmpty);
    });

    test('returns empty cart when buckets not present', () async {
      when(() => mockDio.get<Map<String, dynamic>>('v1/cart')).thenAnswer(
        (_) async => _ok<Map<String, dynamic>>('v1/cart', <String, dynamic>{
          'someOtherKey': 'value',
        }),
      );

      final Cart result = await repo.getCart();
      expect(result.buckets, isEmpty);
    });

    test('unwraps data envelope', () async {
      when(() => mockDio.get<Map<String, dynamic>>('v1/cart')).thenAnswer(
        (_) async => _ok<Map<String, dynamic>>('v1/cart', <String, dynamic>{
          'data': _cartJson(),
        }),
      );

      final Cart result = await repo.getCart();
      expect(result.buckets, hasLength(1));
    });

    test('filters out buckets with no items', () async {
      when(() => mockDio.get<Map<String, dynamic>>('v1/cart')).thenAnswer(
        (_) async => _ok<Map<String, dynamic>>('v1/cart', <String, dynamic>{
          'buckets': <dynamic>[
            <String, dynamic>{
              'seller': <String, dynamic>{'id': 's2'},
              'items': <dynamic>[],
            },
          ],
        }),
      );

      final Cart result = await repo.getCart();
      expect(result.buckets, isEmpty);
    });
  });

  // ── addItem ──────────────────────────────────────────────────────────────

  group('addItem', () {
    test('posts productId to v1/cart/items', () async {
      when(
        () => mockDio.post<dynamic>('v1/cart/items', data: any(named: 'data')),
      ).thenAnswer((_) async => _voidOk('v1/cart/items'));

      await repo.addItem('p1');

      final VerificationResult v = verify(
        () => mockDio.post<dynamic>(
          'v1/cart/items',
          data: captureAny(named: 'data'),
        ),
      );
      final Map<String, dynamic> body =
          v.captured.first as Map<String, dynamic>;
      expect(body['productId'], 'p1');
    });
  });

  // ── removeItem ───────────────────────────────────────────────────────────

  group('removeItem', () {
    test('calls DELETE v1/cart/items/:productId', () async {
      when(
        () => mockDio.delete<dynamic>('v1/cart/items/p1'),
      ).thenAnswer((_) async => _voidOk('v1/cart/items/p1'));

      await repo.removeItem('p1');

      verify(() => mockDio.delete<dynamic>('v1/cart/items/p1')).called(1);
    });
  });
}
