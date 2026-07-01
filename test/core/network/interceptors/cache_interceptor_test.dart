import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/core/network/cache/session_cache.dart';
import 'package:klozy/src/core/network/interceptors/cache_interceptor.dart';
import 'package:mocktail/mocktail.dart';

// ── Mocks / Fakes ─────────────────────────────────────────────────────────────

class _MockSessionCache extends Mock implements SessionCache {}

/// Captures calls to [RequestInterceptorHandler.next] and [resolve].
class _FakeRequestHandler extends Fake implements RequestInterceptorHandler {
  RequestOptions? nextOptions;
  Response<dynamic>? resolvedResponse;
  bool nextCalled = false;
  bool resolveCalled = false;

  @override
  void next(RequestOptions options) {
    nextCalled = true;
    nextOptions = options;
  }

  @override
  void resolve(
    Response<dynamic> response, [
    bool callFollowingResponseInterceptor = false,
  ]) {
    resolveCalled = true;
    resolvedResponse = response;
  }
}

/// Captures calls to [ResponseInterceptorHandler.next].
class _FakeResponseHandler extends Fake implements ResponseInterceptorHandler {
  Response<dynamic>? nextResponse;
  bool wasCalled = false;

  @override
  void next(Response<dynamic> response) {
    wasCalled = true;
    nextResponse = response;
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

RequestOptions _opts({
  String method = 'GET',
  String path = 'https://api.klozy.com/v1/items',
  bool cacheable = false,
  String? group,
}) => RequestOptions(
  path: path,
  method: method,
  extra: <String, dynamic>{
    if (cacheable) kCacheFlag: true,
    if (group != null) kCacheGroup: group,
  },
);

Response<dynamic> _response({
  int statusCode = 200,
  RequestOptions? options,
  Map<String, dynamic>? extra,
  dynamic data = 'body',
}) => Response<dynamic>(
  requestOptions: options ?? _opts(),
  statusCode: statusCode,
  data: data,
  extra: extra ?? <String, dynamic>{},
);

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() {
    // `mockCache.put` takes a `Response<dynamic>` positional arg; mocktail needs
    // a registered fallback before `any()` can match it.
    registerFallbackValue(
      Response<dynamic>(requestOptions: RequestOptions(path: '')),
    );
  });

  late _MockSessionCache mockCache;
  late CacheInterceptor interceptor;

  setUp(() {
    mockCache = _MockSessionCache();
    interceptor = CacheInterceptor(mockCache);
  });

  // ── onRequest ────────────────────────────────────────────────────────────────

  group('onRequest — non-cacheable requests pass through', () {
    test('passes GET without cache flag to handler.next', () {
      final opts = _opts(cacheable: false);
      final handler = _FakeRequestHandler();

      interceptor.onRequest(opts, handler);

      expect(handler.nextCalled, isTrue);
      expect(handler.resolveCalled, isFalse);
      verifyNever(() => mockCache.get(any()));
    });

    test(
      'passes POST with cache flag to handler.next (non-GET is not cacheable)',
      () {
        final opts = _opts(method: 'POST', cacheable: true);
        final handler = _FakeRequestHandler();

        interceptor.onRequest(opts, handler);

        expect(handler.nextCalled, isTrue);
        expect(handler.resolveCalled, isFalse);
        verifyNever(() => mockCache.get(any()));
      },
    );
  });

  group('onRequest — cacheable GET with cache miss', () {
    test('calls handler.next when cache has no entry', () {
      final opts = _opts(cacheable: true, group: 'items');
      when(() => mockCache.get(any())).thenReturn(null);
      final handler = _FakeRequestHandler();

      interceptor.onRequest(opts, handler);

      expect(handler.nextCalled, isTrue);
      expect(handler.resolveCalled, isFalse);
    });
  });

  group('onRequest — cacheable GET with cache hit', () {
    test('calls handler.resolve with cached data instead of forwarding', () {
      final opts = _opts(cacheable: true, group: 'items');
      final cached = _response(data: 'cached body');
      when(() => mockCache.get(any())).thenReturn(cached);
      final handler = _FakeRequestHandler();

      interceptor.onRequest(opts, handler);

      expect(handler.nextCalled, isFalse);
      expect(handler.resolveCalled, isTrue);
    });

    test('resolved response carries from_session_cache: true in extra', () {
      final opts = _opts(cacheable: true, group: 'items');
      final cached = _response(data: 'hit');
      when(() => mockCache.get(any())).thenReturn(cached);
      final handler = _FakeRequestHandler();

      interceptor.onRequest(opts, handler);

      expect(handler.resolvedResponse?.extra['from_session_cache'], isTrue);
    });

    test('resolved response preserves original cached data', () {
      final opts = _opts(cacheable: true);
      final cached = _response(data: <String, dynamic>{'key': 'value'});
      when(() => mockCache.get(any())).thenReturn(cached);
      final handler = _FakeRequestHandler();

      interceptor.onRequest(opts, handler);

      expect(handler.resolvedResponse?.data, cached.data);
    });
  });

  // ── onResponse ───────────────────────────────────────────────────────────────

  group('onResponse — non-cacheable response', () {
    test('passes response to handler.next without storing in cache', () {
      final opts = _opts(cacheable: false);
      final resp = _response(options: opts);
      final handler = _FakeResponseHandler();

      interceptor.onResponse(resp, handler);

      expect(handler.wasCalled, isTrue);
      verifyNever(
        () => mockCache.put(any(), any(), group: any(named: 'group')),
      );
    });
  });

  group('onResponse — cacheable 200 fresh response', () {
    test('stores response in cache and forwards to handler.next', () {
      final opts = _opts(cacheable: true, group: 'items');
      final resp = _response(statusCode: 200, options: opts);
      final handler = _FakeResponseHandler();

      interceptor.onResponse(resp, handler);

      verify(
        () => mockCache.put(any(), any(), group: any(named: 'group')),
      ).called(1);
      expect(handler.wasCalled, isTrue);
      expect(handler.nextResponse, same(resp));
    });

    test('uses the uri string as the cache key', () {
      final opts = _opts(
        cacheable: true,
        path: 'https://api.klozy.com/v1/products',
      );
      final resp = _response(statusCode: 200, options: opts);
      final handler = _FakeResponseHandler();
      String? capturedKey;

      when(
        () => mockCache.put(any(), any(), group: any(named: 'group')),
      ).thenAnswer((invocation) {
        capturedKey = invocation.positionalArguments.first as String;
      });

      interceptor.onResponse(resp, handler);

      expect(capturedKey, contains('v1/products'));
    });
  });

  group('onResponse — cacheable but non-200 status', () {
    test('does not store in cache for a 201 response', () {
      final opts = _opts(cacheable: true, group: 'items');
      final resp = _response(statusCode: 201, options: opts);
      final handler = _FakeResponseHandler();

      interceptor.onResponse(resp, handler);

      verifyNever(
        () => mockCache.put(any(), any(), group: any(named: 'group')),
      );
      expect(handler.wasCalled, isTrue);
    });
  });

  group('onResponse — response already from session cache', () {
    test('does not re-store in cache', () {
      final opts = _opts(cacheable: true, group: 'items');
      final resp = _response(
        statusCode: 200,
        options: opts,
        extra: <String, dynamic>{'from_session_cache': true},
      );
      final handler = _FakeResponseHandler();

      interceptor.onResponse(resp, handler);

      verifyNever(
        () => mockCache.put(any(), any(), group: any(named: 'group')),
      );
      expect(handler.wasCalled, isTrue);
    });
  });
}
