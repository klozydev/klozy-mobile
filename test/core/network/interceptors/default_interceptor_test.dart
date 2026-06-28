import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:klozy/src/core/network/interceptors/default_interceptor.dart';

// ── Fakes ─────────────────────────────────────────────────────────────────────

/// Captures the options passed to [RequestInterceptorHandler.next].
class _FakeRequestHandler extends Fake implements RequestInterceptorHandler {
  RequestOptions? nextOptions;
  bool wasCalled = false;

  @override
  void next(RequestOptions options) {
    wasCalled = true;
    nextOptions = options;
  }
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late DefaultInterceptor interceptor;

  setUp(() {
    interceptor = const DefaultInterceptor();
    // Reset locale so tests are deterministic.
    Intl.defaultLocale = null;
  });

  tearDown(() {
    Intl.defaultLocale = null;
  });

  // ── Header values ─────────────────────────────────────────────────────────────

  group('onRequest — default headers', () {
    test('sets Accept to application/json', () {
      final opts = RequestOptions(path: '/test');
      final handler = _FakeRequestHandler();

      interceptor.onRequest(opts, handler);

      expect(handler.nextOptions!.headers['Accept'], 'application/json');
    });

    test('sets Content-Type to application/json', () {
      final opts = RequestOptions(path: '/test');
      final handler = _FakeRequestHandler();

      interceptor.onRequest(opts, handler);

      expect(handler.nextOptions!.headers['Content-Type'], 'application/json');
    });

    test('sets Accept-Language to "en" when no locale is configured', () {
      final opts = RequestOptions(path: '/test');
      final handler = _FakeRequestHandler();

      interceptor.onRequest(opts, handler);

      expect(handler.nextOptions!.headers['Accept-Language'], 'en');
    });

    test('sets X-Language to "en" when no locale is configured', () {
      final opts = RequestOptions(path: '/test');
      final handler = _FakeRequestHandler();

      interceptor.onRequest(opts, handler);

      expect(handler.nextOptions!.headers['X-Language'], 'en');
    });
  });

  // ── Locale extraction ─────────────────────────────────────────────────────────

  group('onRequest — locale extraction', () {
    test('extracts language code from a full locale tag (e.g. fr_FR → fr)', () {
      Intl.defaultLocale = 'fr_FR';
      final opts = RequestOptions(path: '/test');
      final handler = _FakeRequestHandler();

      interceptor.onRequest(opts, handler);

      expect(handler.nextOptions!.headers['X-Language'], 'fr');
      expect(handler.nextOptions!.headers['Accept-Language'], 'fr');
    });

    test('extracts language code from BCP-47 tag (e.g. ar-MA → ar)', () {
      Intl.defaultLocale = 'ar-MA';
      final opts = RequestOptions(path: '/test');
      final handler = _FakeRequestHandler();

      interceptor.onRequest(opts, handler);

      expect(handler.nextOptions!.headers['X-Language'], 'ar');
      expect(handler.nextOptions!.headers['Accept-Language'], 'ar');
    });

    test('uses bare language code as-is (e.g. "de" → "de")', () {
      Intl.defaultLocale = 'de';
      final opts = RequestOptions(path: '/test');
      final handler = _FakeRequestHandler();

      interceptor.onRequest(opts, handler);

      expect(handler.nextOptions!.headers['X-Language'], 'de');
    });
  });

  // ── Handler forwarding ────────────────────────────────────────────────────────

  group('onRequest — handler forwarding', () {
    test('calls handler.next with the (mutated) options', () {
      final opts = RequestOptions(path: '/test');
      final handler = _FakeRequestHandler();

      interceptor.onRequest(opts, handler);

      expect(handler.wasCalled, isTrue);
      // The options object is mutated in-place; same instance is forwarded.
      expect(handler.nextOptions, same(opts));
    });
  });
}
