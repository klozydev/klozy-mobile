// test/data/product/products_repository_impl_test.dart

import 'package:dio/dio.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/core/network/cache/session_cache.dart';
import 'package:klozy/src/data/product/products_repository_impl.dart';
import 'package:klozy/src/domain/product/entity/create_product_input.dart';
import 'package:klozy/src/domain/product/entity/feed_page.dart';
import 'package:klozy/src/domain/product/entity/product_detail.dart';
import 'package:klozy/src/domain/product/entity/search_result.dart';
import 'package:klozy/src/domain/product/products_repository.dart';
import 'package:mocktail/mocktail.dart';

// ── Mocks ──────────────────────────────────────────────────────────────────

class _MockDio extends Mock implements Dio {}

class _MockEventBus extends Mock implements EventBus {}

class _MockSessionCache extends Mock implements SessionCache {}

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

/// Minimal paginated product list envelope.
Map<String, dynamic> _paginatedProducts(
  List<Map<String, dynamic>> items, {
  List<String>? pickedForYou,
}) => <String, dynamic>{
  'items': items,
  'page': 1,
  'limit': 20,
  'total': items.length,
  if (pickedForYou != null) 'pickedForYou': pickedForYou,
};

Map<String, dynamic> _productJson({String id = 'p1'}) => <String, dynamic>{
  'id': id,
  'title': 'Item $id',
  'price': 50,
};

void main() {
  late _MockDio mockDio;
  late _MockEventBus mockEventBus;
  late _MockSessionCache mockCache;
  late ProductsRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(Options());
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    mockDio = _MockDio();
    mockEventBus = _MockEventBus();
    mockCache = _MockSessionCache();

    when(() => mockEventBus.fire(any())).thenAnswer((_) {});
    when(() => mockCache.invalidateGroup(any())).thenAnswer((_) {});

    repo = ProductsRepositoryImpl(mockDio, mockEventBus, mockCache);
  });

  // ── feed ─────────────────────────────────────────────────────────────────

  group('feed', () {
    test('returns mapped FeedPage with products and pickedForYou', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          'v1/products',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => _ok<Map<String, dynamic>>(
          'v1/products',
          _paginatedProducts(
            <Map<String, dynamic>>[
              _productJson(id: 'p1'),
              _productJson(id: 'p2'),
            ],
            pickedForYou: <String>['p1'],
          ),
        ),
      );

      final FeedPage result = await repo.feed();

      expect(result.data, hasLength(2));
      expect(result.data[0].id, 'p1');
      expect(result.pickedForYou, contains('p1'));
    });

    test('passes sort/page/limit as query parameters', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          'v1/products',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => _ok<Map<String, dynamic>>(
          'v1/products',
          _paginatedProducts(<Map<String, dynamic>>[]),
        ),
      );

      await repo.feed(sort: ProductSort.latest, page: 2, limit: 10);

      final VerificationResult v = verify(
        () => mockDio.get<Map<String, dynamic>>(
          'v1/products',
          queryParameters: captureAny(named: 'queryParameters'),
        ),
      );
      final Map<String, dynamic> params =
          v.captured.first as Map<String, dynamic>;
      expect(params['sort'], ProductSort.latest.value);
      expect(params['page'], 2);
      expect(params['limit'], 10);
    });

    test('includes optional filters when provided', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          'v1/products',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => _ok<Map<String, dynamic>>(
          'v1/products',
          _paginatedProducts(<Map<String, dynamic>>[]),
        ),
      );

      await repo.feed(rootCategoryId: 'root1', categoryId: 'cat2');

      final VerificationResult v = verify(
        () => mockDio.get<Map<String, dynamic>>(
          'v1/products',
          queryParameters: captureAny(named: 'queryParameters'),
        ),
      );
      final Map<String, dynamic> params =
          v.captured.first as Map<String, dynamic>;
      expect(params['rootCategoryId'], 'root1');
      expect(params['categoryId'], 'cat2');
    });
  });

  // ── search ────────────────────────────────────────────────────────────────

  group('search', () {
    test('maps SearchResult with facets', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          'v1/products/search',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async =>
            _ok<Map<String, dynamic>>('v1/products/search', <String, dynamic>{
              'items': <dynamic>[_productJson()],
              'facets': <String, dynamic>{
                'brands': <dynamic>[
                  <String, dynamic>{'key': 'Nike', 'count': 5},
                ],
                'conditions': <dynamic>[
                  <String, dynamic>{'key': 'good', 'count': 3},
                ],
                'priceMin': 10,
                'priceMax': 500,
              },
            }),
      );

      final SearchResult result = await repo.search(query: 'nike');

      expect(result.page.data, hasLength(1));
      expect(result.facets.brands, hasLength(1));
      expect(result.facets.brands.first.key, 'Nike');
      expect(result.facets.priceMin, 10);
      expect(result.facets.priceMax, 500);
    });

    test('passes filters as query parameters', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          'v1/products/search',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => _ok<Map<String, dynamic>>(
          'v1/products/search',
          <String, dynamic>{'items': <dynamic>[]},
        ),
      );

      await repo.search(
        query: 'dress',
        conditions: <String>['new', 'good'],
        sizes: <String>['S', 'M'],
        brandIds: <String>['b1'],
        minPrice: 10,
        maxPrice: 200,
      );

      final VerificationResult v = verify(
        () => mockDio.get<Map<String, dynamic>>(
          'v1/products/search',
          queryParameters: captureAny(named: 'queryParameters'),
        ),
      );
      final Map<String, dynamic> params =
          v.captured.first as Map<String, dynamic>;
      expect(params['q'], 'dress');
      expect(params['conditions'], 'new,good');
      expect(params['sizes'], 'S,M');
      expect(params['brandIds'], 'b1');
      expect(params['minPrice'], 10);
      expect(params['maxPrice'], 200);
    });

    test('omits empty query from params', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          'v1/products/search',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => _ok<Map<String, dynamic>>(
          'v1/products/search',
          <String, dynamic>{'items': <dynamic>[]},
        ),
      );

      await repo.search();

      final VerificationResult v = verify(
        () => mockDio.get<Map<String, dynamic>>(
          'v1/products/search',
          queryParameters: captureAny(named: 'queryParameters'),
        ),
      );
      final Map<String, dynamic> params =
          v.captured.first as Map<String, dynamic>;
      expect(params.containsKey('q'), isFalse);
    });

    test('returns empty SearchFacets when facets absent', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          'v1/products/search',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => _ok<Map<String, dynamic>>(
          'v1/products/search',
          <String, dynamic>{'items': <dynamic>[]},
        ),
      );

      final SearchResult result = await repo.search();
      expect(result.facets.brands, isEmpty);
      expect(result.facets.conditions, isEmpty);
    });
  });

  // ── getProduct ───────────────────────────────────────────────────────────

  group('getProduct', () {
    test('maps product detail from wrapped data key', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          'v1/products/p1',
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async =>
            _ok<Map<String, dynamic>>('v1/products/p1', <String, dynamic>{
              'data': <String, dynamic>{
                'id': 'p1',
                'title': 'Blue Jeans',
                'price': 120,
                'brand': "Levi's",
                'size': '32',
                'description': 'Classic jeans.',
                'status': 'ACTIVE',
                'seller': <String, dynamic>{
                  'id': 's1',
                  'displayName': 'Seller One',
                },
              },
            }),
      );

      final ProductDetail result = await repo.getProduct('p1');

      expect(result.id, 'p1');
      expect(result.title, 'Blue Jeans');
      expect(result.price, 120);
      expect(result.status, ProductStatus.active);
      expect(result.seller.displayName, 'Seller One');
    });

    test('maps bare product object (no data wrapper)', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          'v1/products/p2',
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async =>
            _ok<Map<String, dynamic>>('v1/products/p2', <String, dynamic>{
              'id': 'p2',
              'title': 'Red Shirt',
              'price': 50,
              'status': 'SOLD',
              'seller': <String, dynamic>{},
            }),
      );

      final ProductDetail result = await repo.getProduct('p2');
      expect(result.id, 'p2');
      expect(result.status, ProductStatus.sold);
    });
  });

  // ── updateStatus ─────────────────────────────────────────────────────────

  group('updateStatus', () {
    test('patches status and invalidates cache + fires event', () async {
      when(
        () =>
            mockDio.patch<dynamic>('v1/products/p1', data: any(named: 'data')),
      ).thenAnswer((_) async => _voidOk('v1/products/p1'));

      await repo.updateStatus('p1', ProductStatus.sold);

      verify(
        () =>
            mockDio.patch<dynamic>('v1/products/p1', data: any(named: 'data')),
      ).called(1);
      verify(() => mockCache.invalidateGroup('products')).called(1);
      verify(() => mockEventBus.fire(any())).called(1);
    });
  });

  // ── deleteProduct ────────────────────────────────────────────────────────

  group('deleteProduct', () {
    test('deletes and invalidates cache + fires event', () async {
      when(
        () => mockDio.delete<dynamic>('v1/products/p1'),
      ).thenAnswer((_) async => _voidOk('v1/products/p1'));

      await repo.deleteProduct('p1');

      verify(() => mockDio.delete<dynamic>('v1/products/p1')).called(1);
      verify(() => mockCache.invalidateGroup('products')).called(1);
      verify(() => mockEventBus.fire(any())).called(1);
    });
  });

  // ── reportProduct ────────────────────────────────────────────────────────

  group('reportProduct', () {
    test('posts reason and invalidates cache', () async {
      when(
        () => mockDio.post<dynamic>(
          'v1/products/p1/report',
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => _voidOk('v1/products/p1/report'));

      await repo.reportProduct('p1', 'counterfeit');

      final VerificationResult v = verify(
        () => mockDio.post<dynamic>(
          'v1/products/p1/report',
          data: captureAny(named: 'data'),
        ),
      );
      final Map<String, dynamic> body =
          v.captured.first as Map<String, dynamic>;
      expect(body['reason'], 'counterfeit');
      verify(() => mockCache.invalidateGroup('products')).called(1);
    });
  });

  // ── createProduct ────────────────────────────────────────────────────────

  group('createProduct', () {
    test('posts and returns id from data.id', () async {
      when(
        () => mockDio.post<Map<String, dynamic>>(
          'v1/products',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => _ok<Map<String, dynamic>>('v1/products', <String, dynamic>{
          'data': <String, dynamic>{'id': 'new-prod-1'},
        }),
      );

      // Use a minimal CreateProductInput — we just verify the id is extracted.
      // The exact fields depend on CreateProductInput; we use toJson() indirectly.
      final String id = await repo.createProduct(
        const CreateProductInput(
          title: 'Test',
          price: 99,
          categoryId: 'cat1',
          conditionId: 'good',
          size: 'M',
          brandId: 'b1',
          brandName: 'Nike',
          description: 'A test product',
          images: <String>['https://example.com/img.jpg'],
        ),
      );

      expect(id, 'new-prod-1');
      verify(() => mockCache.invalidateGroup('products')).called(1);
      verify(() => mockEventBus.fire(any())).called(1);
    });

    test('returns empty string when id missing', () async {
      when(
        () => mockDio.post<Map<String, dynamic>>(
          'v1/products',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async =>
            _ok<Map<String, dynamic>>('v1/products', <String, dynamic>{}),
      );

      final String id = await repo.createProduct(
        const CreateProductInput(
          title: 'T',
          price: 1,
          categoryId: 'c',
          conditionId: 'g',
          size: 'S',
          brandId: 'b',
          brandName: 'X',
          description: 'D',
          images: <String>[],
        ),
      );

      expect(id, '');
    });
  });

  // ── updateProduct ────────────────────────────────────────────────────────

  group('updateProduct', () {
    test('patches with provided fields and invalidates cache', () async {
      when(
        () =>
            mockDio.patch<dynamic>('v1/products/p1', data: any(named: 'data')),
      ).thenAnswer((_) async => _voidOk('v1/products/p1'));

      await repo.updateProduct('p1', title: 'Updated Title', price: 150);

      final VerificationResult v = verify(
        () => mockDio.patch<dynamic>(
          'v1/products/p1',
          data: captureAny(named: 'data'),
        ),
      );
      final Map<String, dynamic> body =
          v.captured.first as Map<String, dynamic>;
      expect(body['title'], 'Updated Title');
      expect(body['price'], 150);
      expect(body.containsKey('size'), isFalse);
      verify(() => mockCache.invalidateGroup('products')).called(1);
      verify(() => mockEventBus.fire(any())).called(1);
    });
  });
}
