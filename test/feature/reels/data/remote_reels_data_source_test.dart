// NOTE: RemoteReelsDataSource.uploadVideo creates a new Dio() instance
// internally and reads from the filesystem, making it genuinely untestable with
// the available tooling (mocktail cannot intercept the ad-hoc Dio). That single
// method is the only gap in this file.

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/reels/data/datasource/remote_reels_data_source.dart';
import 'package:mocktail/mocktail.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────────

class _MockDio extends Mock implements Dio {}

// ── Helpers ───────────────────────────────────────────────────────────────────

Response<T> _ok<T>(T data, {String path = ''}) => Response<T>(
  requestOptions: RequestOptions(path: path),
  statusCode: 200,
  data: data,
);

Response<T> _nullDataResponse<T>({String path = ''}) => Response<T>(
  requestOptions: RequestOptions(path: path),
  statusCode: 200,
  data: null,
);

RemoteReelsDataSource _datasource(_MockDio dio) => RemoteReelsDataSource(dio);

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late _MockDio mockDio;

  setUpAll(() {
    // Options is used by cacheable(). Register a fallback so any() matchers work.
    registerFallbackValue(Options());
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    mockDio = _MockDio();
  });

  // ── feed ─────────────────────────────────────────────────────────────────────

  group('feed', () {
    test('sends GET to v1/reels with page and limit as query params', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          'v1/reels',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => _ok(<String, dynamic>{'items': <dynamic>[]}));

      final ds = _datasource(mockDio);
      await ds.feed(page: 2, limit: 5);

      final calls = verify(
        () => mockDio.get<Map<String, dynamic>>(
          'v1/reels',
          queryParameters: captureAny(named: 'queryParameters'),
        ),
      ).captured;
      final params = calls.first as Map<String, dynamic>;
      expect(params['page'], 2);
      expect(params['limit'], 5);
    });

    test('returns the raw response data map', () async {
      final payload = <String, dynamic>{'items': <dynamic>[], 'total': 0};
      when(
        () => mockDio.get<Map<String, dynamic>>(
          'v1/reels',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => _ok(payload));

      final ds = _datasource(mockDio);
      final result = await ds.feed(page: 1, limit: 10);

      expect(result, payload);
    });

    test('returns empty map when response.data is null', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          'v1/reels',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => _nullDataResponse());

      final ds = _datasource(mockDio);
      final result = await ds.feed(page: 1, limit: 10);

      expect(result, isEmpty);
    });
  });

  // ── getOne ────────────────────────────────────────────────────────────────────

  group('getOne', () {
    test('sends GET to v1/reels/{id} with cacheable options', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          'v1/reels/r1',
          options: any(named: 'options'),
        ),
      ).thenAnswer((_) async => _ok(<String, dynamic>{'id': 'r1'}));

      final ds = _datasource(mockDio);
      final result = await ds.getOne('r1');

      expect(result['id'], 'r1');
      verify(
        () => mockDio.get<Map<String, dynamic>>(
          'v1/reels/r1',
          options: any(named: 'options'),
        ),
      ).called(1);
    });

    test('returns empty map when response.data is null', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          any(),
          options: any(named: 'options'),
        ),
      ).thenAnswer((_) async => _nullDataResponse());

      final ds = _datasource(mockDio);
      expect(await ds.getOne('r1'), isEmpty);
    });
  });

  // ── update ────────────────────────────────────────────────────────────────────

  group('update', () {
    test('sends PATCH to v1/reels/{id} with body', () async {
      when(
        () => mockDio.patch<dynamic>('v1/reels/r1', data: any(named: 'data')),
      ).thenAnswer((_) async => _ok<dynamic>(null));

      final ds = _datasource(mockDio);
      await ds.update('r1', <String, dynamic>{'caption': 'new'});

      final calls = verify(
        () => mockDio.patch<dynamic>(
          'v1/reels/r1',
          data: captureAny(named: 'data'),
        ),
      ).captured;
      expect((calls.first as Map<String, dynamic>)['caption'], 'new');
    });
  });

  // ── comments ──────────────────────────────────────────────────────────────────

  group('comments', () {
    test(
      'sends GET to v1/reels/{id}/comments with page and limit=50',
      () async {
        when(
          () => mockDio.get<dynamic>(
            'v1/reels/r1/comments',
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer((_) async => _ok<dynamic>(<dynamic>[]));

        final ds = _datasource(mockDio);
        await ds.comments('r1', page: 3);

        final calls = verify(
          () => mockDio.get<dynamic>(
            'v1/reels/r1/comments',
            queryParameters: captureAny(named: 'queryParameters'),
          ),
        ).captured;
        final params = calls.first as Map<String, dynamic>;
        expect(params['page'], 3);
        expect(params['limit'], 50);
      },
    );

    test('returns the raw response.data', () async {
      final list = <dynamic>[
        <String, dynamic>{'id': 'c1'},
      ];
      when(
        () => mockDio.get<dynamic>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => _ok<dynamic>(list));

      final ds = _datasource(mockDio);
      expect(await ds.comments('r1', page: 1), same(list));
    });
  });

  // ── addComment ────────────────────────────────────────────────────────────────

  group('addComment', () {
    test('sends POST to v1/reels/{id}/comments with body', () async {
      when(
        () => mockDio.post<Map<String, dynamic>>(
          'v1/reels/r1/comments',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => _ok(<String, dynamic>{'id': 'c-new', 'body': 'Great!'}),
      );

      final ds = _datasource(mockDio);
      final result = await ds.addComment('r1', 'Great!');

      expect(result['id'], 'c-new');
      final calls = verify(
        () => mockDio.post<Map<String, dynamic>>(
          'v1/reels/r1/comments',
          data: captureAny(named: 'data'),
        ),
      ).captured;
      expect((calls.first as Map<String, dynamic>)['body'], 'Great!');
    });

    test('returns empty map when response.data is null', () async {
      when(
        () =>
            mockDio.post<Map<String, dynamic>>(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => _nullDataResponse());

      final ds = _datasource(mockDio);
      expect(await ds.addComment('r1', 'x'), isEmpty);
    });
  });

  // ── deleteComment ─────────────────────────────────────────────────────────────

  group('deleteComment', () {
    test('sends DELETE to v1/reels/{id}/comments/{commentId}', () async {
      when(
        () => mockDio.delete<dynamic>('v1/reels/r1/comments/c1'),
      ).thenAnswer((_) async => _ok<dynamic>(null));

      final ds = _datasource(mockDio);
      await ds.deleteComment('r1', 'c1');

      verify(
        () => mockDio.delete<dynamic>('v1/reels/r1/comments/c1'),
      ).called(1);
    });
  });

  // ── like ─────────────────────────────────────────────────────────────────────

  group('like', () {
    test('sends PUT to v1/reels/{id}/like', () async {
      when(
        () => mockDio.put<dynamic>('v1/reels/r1/like'),
      ).thenAnswer((_) async => _ok<dynamic>(null));

      final ds = _datasource(mockDio);
      await ds.like('r1');

      verify(() => mockDio.put<dynamic>('v1/reels/r1/like')).called(1);
    });
  });

  // ── unlike ────────────────────────────────────────────────────────────────────

  group('unlike', () {
    test('sends DELETE to v1/reels/{id}/like', () async {
      when(
        () => mockDio.delete<dynamic>('v1/reels/r1/like'),
      ).thenAnswer((_) async => _ok<dynamic>(null));

      final ds = _datasource(mockDio);
      await ds.unlike('r1');

      verify(() => mockDio.delete<dynamic>('v1/reels/r1/like')).called(1);
    });
  });

  // ── view ─────────────────────────────────────────────────────────────────────

  group('view', () {
    test('sends POST to v1/reels/{id}/view', () async {
      when(
        () => mockDio.post<dynamic>('v1/reels/r1/view'),
      ).thenAnswer((_) async => _ok<dynamic>(null));

      final ds = _datasource(mockDio);
      await ds.view('r1');

      verify(() => mockDio.post<dynamic>('v1/reels/r1/view')).called(1);
    });
  });

  // ── report ────────────────────────────────────────────────────────────────────

  group('report', () {
    test('sends POST to v1/reels/{id}/report with reason', () async {
      when(
        () => mockDio.post<dynamic>(
          'v1/reels/r1/report',
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => _ok<dynamic>(null));

      final ds = _datasource(mockDio);
      await ds.report('r1', 'spam');

      final calls = verify(
        () => mockDio.post<dynamic>(
          'v1/reels/r1/report',
          data: captureAny(named: 'data'),
        ),
      ).captured;
      expect((calls.first as Map<String, dynamic>)['reason'], 'spam');
    });
  });

  // ── delete ────────────────────────────────────────────────────────────────────

  group('delete', () {
    test('sends DELETE to v1/reels/{id}', () async {
      when(
        () => mockDio.delete<dynamic>('v1/reels/r1'),
      ).thenAnswer((_) async => _ok<dynamic>(null));

      final ds = _datasource(mockDio);
      await ds.delete('r1');

      verify(() => mockDio.delete<dynamic>('v1/reels/r1')).called(1);
    });
  });

  // ── shopTheLook ───────────────────────────────────────────────────────────────

  group('shopTheLook', () {
    test(
      'sends GET to v1/reels/{id}/products with cacheable options',
      () async {
        final products = <dynamic>[
          <String, dynamic>{'id': 'p1'},
        ];
        when(
          () => mockDio.get<List<dynamic>>(
            'v1/reels/r1/products',
            options: any(named: 'options'),
          ),
        ).thenAnswer((_) async => _ok(products));

        final ds = _datasource(mockDio);
        final result = await ds.shopTheLook('r1');

        expect(result, products);
        verify(
          () => mockDio.get<List<dynamic>>(
            'v1/reels/r1/products',
            options: any(named: 'options'),
          ),
        ).called(1);
      },
    );

    test('returns empty list when response.data is null', () async {
      when(
        () => mockDio.get<List<dynamic>>(any(), options: any(named: 'options')),
      ).thenAnswer((_) async => _nullDataResponse());

      final ds = _datasource(mockDio);
      expect(await ds.shopTheLook('r1'), isEmpty);
    });
  });

  // ── userProducts ──────────────────────────────────────────────────────────────

  group('userProducts', () {
    void stubUserProducts(_MockDio dio, Object? data) {
      when(
        () => dio.get<dynamic>(
          'v1/users/u1/products',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => _ok<dynamic>(data));
    }

    test('returns bare list response directly', () async {
      final list = <dynamic>['a', 'b'];
      stubUserProducts(mockDio, list);

      final ds = _datasource(mockDio);
      expect(await ds.userProducts('u1'), same(list));
    });

    test('extracts list from "data" envelope key', () async {
      final list = <dynamic>[1, 2, 3];
      stubUserProducts(mockDio, <String, dynamic>{'data': list});

      final ds = _datasource(mockDio);
      expect(await ds.userProducts('u1'), same(list));
    });

    test('extracts list from "items" envelope key', () async {
      final list = <dynamic>[1, 2];
      stubUserProducts(mockDio, <String, dynamic>{'items': list});

      final ds = _datasource(mockDio);
      expect(await ds.userProducts('u1'), same(list));
    });

    test('extracts list from "results" envelope key', () async {
      final list = <dynamic>['r'];
      stubUserProducts(mockDio, <String, dynamic>{'results': list});

      final ds = _datasource(mockDio);
      expect(await ds.userProducts('u1'), same(list));
    });

    test('extracts list from "products" envelope key', () async {
      final list = <dynamic>['p'];
      stubUserProducts(mockDio, <String, dynamic>{'products': list});

      final ds = _datasource(mockDio);
      expect(await ds.userProducts('u1'), same(list));
    });

    test('returns empty list when envelope has no recognised key', () async {
      stubUserProducts(mockDio, <String, dynamic>{'unknown': <dynamic>[]});

      final ds = _datasource(mockDio);
      expect(await ds.userProducts('u1'), isEmpty);
    });

    test('returns empty list when response.data is null', () async {
      stubUserProducts(mockDio, null);

      final ds = _datasource(mockDio);
      expect(await ds.userProducts('u1'), isEmpty);
    });
  });

  // ── createReel ────────────────────────────────────────────────────────────────

  group('createReel', () {
    test('sends POST to v1/reels with caption and taggedProductIds', () async {
      when(
        () => mockDio.post<Map<String, dynamic>>(
          'v1/reels',
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => _ok(<String, dynamic>{'id': 'reel-1'}));

      final ds = _datasource(mockDio);
      await ds.createReel(
        caption: 'Hello world',
        taggedProductIds: <String>['p1', 'p2'],
      );

      final calls = verify(
        () => mockDio.post<Map<String, dynamic>>(
          'v1/reels',
          data: captureAny(named: 'data'),
        ),
      ).captured;
      final body = calls.first as Map<String, dynamic>;
      expect(body['caption'], 'Hello world');
      expect(body['taggedProductIds'], <String>['p1', 'p2']);
    });

    test('omits caption from body when caption is null', () async {
      when(
        () => mockDio.post<Map<String, dynamic>>(
          'v1/reels',
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => _ok(<String, dynamic>{}));

      final ds = _datasource(mockDio);
      await ds.createReel(taggedProductIds: <String>[]);

      final calls = verify(
        () => mockDio.post<Map<String, dynamic>>(
          'v1/reels',
          data: captureAny(named: 'data'),
        ),
      ).captured;
      expect(
        (calls.first as Map<String, dynamic>).containsKey('caption'),
        isFalse,
      );
    });

    test('omits caption from body when caption is empty string', () async {
      when(
        () => mockDio.post<Map<String, dynamic>>(
          'v1/reels',
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => _ok(<String, dynamic>{}));

      final ds = _datasource(mockDio);
      await ds.createReel(caption: '', taggedProductIds: <String>[]);

      final calls = verify(
        () => mockDio.post<Map<String, dynamic>>(
          'v1/reels',
          data: captureAny(named: 'data'),
        ),
      ).captured;
      expect(
        (calls.first as Map<String, dynamic>).containsKey('caption'),
        isFalse,
      );
    });

    test('returns empty map when response.data is null', () async {
      when(
        () => mockDio.post<Map<String, dynamic>>(
          'v1/reels',
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => _nullDataResponse());

      final ds = _datasource(mockDio);
      expect(await ds.createReel(taggedProductIds: <String>[]), isEmpty);
    });
  });
}
