// test/data/wishlist/wishlist_repository_impl_test.dart

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/core/pagination/paginated_list.dart';
import 'package:klozy/src/data/wishlist/wishlist_repository_impl.dart';
import 'package:klozy/src/domain/product/entity/product.dart';
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

/// Minimal paginated wishlist response envelope.
Map<String, dynamic> _paginatedEnvelope(List<Map<String, dynamic>> items) =>
    <String, dynamic>{
      'items': items,
      'page': 1,
      'limit': 20,
      'total': items.length,
    };

Map<String, dynamic> _productJson({
  String id = 'p1',
  String title = 'Blue Dress',
  num price = 120,
}) => <String, dynamic>{
  'id': id,
  'title': title,
  'price': price,
  'brand': 'Zara',
  'size': 'S',
};

void main() {
  late _MockDio mockDio;
  late WishlistRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(Options());
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    mockDio = _MockDio();
    repo = WishlistRepositoryImpl(mockDio);
  });

  // ── getWishlistProducts ──────────────────────────────────────────────────

  group('getWishlistProducts', () {
    test('maps paginated product list from items key', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          'v1/me/wishlist',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => _ok<Map<String, dynamic>>(
          'v1/me/wishlist',
          _paginatedEnvelope(<Map<String, dynamic>>[
            _productJson(id: 'p1', title: 'Blue Dress'),
            _productJson(id: 'p2', title: 'Red Bag'),
          ]),
        ),
      );

      final PaginatedList<Product> result = await repo.getWishlistProducts(
        page: 1,
        limit: 20,
      );

      expect(result.data, hasLength(2));
      expect(result.data[0].id, 'p1');
      expect(result.data[0].title, 'Blue Dress');
      expect(result.data[1].id, 'p2');
      expect(result.metadata, isNotNull);
    });

    test('sends page and limit as query parameters', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          'v1/me/wishlist',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => _ok<Map<String, dynamic>>(
          'v1/me/wishlist',
          _paginatedEnvelope(<Map<String, dynamic>>[]),
        ),
      );

      await repo.getWishlistProducts(page: 2, limit: 10);

      final VerificationResult v = verify(
        () => mockDio.get<Map<String, dynamic>>(
          'v1/me/wishlist',
          queryParameters: captureAny(named: 'queryParameters'),
        ),
      );
      final Map<String, dynamic> params =
          v.captured.first as Map<String, dynamic>;
      expect(params['page'], 2);
      expect(params['limit'], 10);
    });

    test('returns empty list when response data is empty', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          'v1/me/wishlist',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async =>
            _ok<Map<String, dynamic>>('v1/me/wishlist', <String, dynamic>{}),
      );

      final PaginatedList<Product> result = await repo.getWishlistProducts();

      expect(result.data, isEmpty);
    });
  });

  // ── getWishlistProductIds ────────────────────────────────────────────────

  group('getWishlistProductIds', () {
    test('returns set of product ids', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          'v1/me/wishlist',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => _ok<Map<String, dynamic>>(
          'v1/me/wishlist',
          _paginatedEnvelope(<Map<String, dynamic>>[
            _productJson(id: 'p1'),
            _productJson(id: 'p2'),
            _productJson(id: 'p3'),
          ]),
        ),
      );

      final Set<String> ids = await repo.getWishlistProductIds();

      expect(ids, containsAll(<String>['p1', 'p2', 'p3']));
      expect(ids, hasLength(3));
    });

    test('excludes products with empty id', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          'v1/me/wishlist',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async =>
            _ok<Map<String, dynamic>>('v1/me/wishlist', <String, dynamic>{
              'items': <dynamic>[
                <String, dynamic>{'id': 'p1', 'title': 'T', 'price': 10},
                <String, dynamic>{'title': 'No-id', 'price': 10},
              ],
            }),
      );

      final Set<String> ids = await repo.getWishlistProductIds();
      expect(ids, contains('p1'));
      expect(ids, hasLength(1));
    });
  });

  // ── add ─────────────────────────────────────────────────────────────────

  group('add', () {
    test('calls PUT v1/me/wishlist/:productId', () async {
      when(
        () => mockDio.put<dynamic>('v1/me/wishlist/p1'),
      ).thenAnswer((_) async => _voidOk('v1/me/wishlist/p1'));

      await repo.add('p1');

      verify(() => mockDio.put<dynamic>('v1/me/wishlist/p1')).called(1);
    });
  });

  // ── remove ──────────────────────────────────────────────────────────────

  group('remove', () {
    test('calls DELETE v1/me/wishlist/:productId', () async {
      when(
        () => mockDio.delete<dynamic>('v1/me/wishlist/p1'),
      ).thenAnswer((_) async => _voidOk('v1/me/wishlist/p1'));

      await repo.remove('p1');

      verify(() => mockDio.delete<dynamic>('v1/me/wishlist/p1')).called(1);
    });
  });
}
