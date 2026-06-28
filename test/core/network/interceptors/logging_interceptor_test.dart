import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/core/network/interceptors/logging_interceptor.dart';
import 'package:klozy/src/core/observability/app_logger.dart';
import 'package:mocktail/mocktail.dart';

// ── Mocks / Fakes ─────────────────────────────────────────────────────────────

class _MockAppLogger extends Mock implements AppLogger {}

/// Captures the last call to [RequestInterceptorHandler.next].
class _FakeRequestHandler extends Fake implements RequestInterceptorHandler {
  RequestOptions? nextOptions;
  bool wasCalled = false;

  @override
  void next(RequestOptions options) {
    wasCalled = true;
    nextOptions = options;
  }
}

/// Captures the last call to [ResponseInterceptorHandler.next].
class _FakeResponseHandler extends Fake implements ResponseInterceptorHandler {
  Response<dynamic>? nextResponse;
  bool wasCalled = false;

  @override
  void next(Response<dynamic> response) {
    wasCalled = true;
    nextResponse = response;
  }
}

/// Captures the last call to [ErrorInterceptorHandler.next].
class _FakeErrorHandler extends Fake implements ErrorInterceptorHandler {
  DioException? nextError;
  bool wasCalled = false;

  @override
  void next(DioException err) {
    wasCalled = true;
    nextError = err;
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

RequestOptions _requestOptions({
  String method = 'GET',
  String path = '/test',
  dynamic data,
}) => RequestOptions(path: path, method: method, data: data);

Response<dynamic> _response({
  int statusCode = 200,
  dynamic data,
  RequestOptions? options,
}) => Response<dynamic>(
  requestOptions: options ?? _requestOptions(),
  statusCode: statusCode,
  data: data,
);

DioException _dioError({int? statusCode, RequestOptions? options}) {
  final opts = options ?? _requestOptions();
  return DioException(
    requestOptions: opts,
    response: statusCode != null
        ? Response<dynamic>(requestOptions: opts, statusCode: statusCode)
        : null,
    type: statusCode != null
        ? DioExceptionType.badResponse
        : DioExceptionType.connectionError,
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late _MockAppLogger mockLogger;
  late LoggingInterceptor interceptor;

  setUpAll(() {
    // Fallback for Map<String, Object?> used as the `attributes` argument.
    registerFallbackValue(<String, Object?>{});
    registerFallbackValue(StackTrace.empty);
  });

  setUp(() {
    mockLogger = _MockAppLogger();
    interceptor = LoggingInterceptor(mockLogger);
  });

  // ── onRequest ────────────────────────────────────────────────────────────────

  group('onRequest', () {
    test('calls logger.info and forwards options to handler.next', () {
      final opts = _requestOptions(method: 'POST', path: '/items');
      final handler = _FakeRequestHandler();

      interceptor.onRequest(opts, handler);

      verify(
        () => mockLogger.info(any(), attributes: any(named: 'attributes')),
      ).called(1);
      expect(handler.wasCalled, isTrue);
      expect(handler.nextOptions, same(opts));
    });

    test('includes method and uri in the logged message', () {
      final opts = _requestOptions(method: 'DELETE', path: '/users/42');
      final handler = _FakeRequestHandler();
      String? capturedMessage;

      when(
        () => mockLogger.info(any(), attributes: any(named: 'attributes')),
      ).thenAnswer((invocation) {
        capturedMessage = invocation.positionalArguments.first as String;
      });

      interceptor.onRequest(opts, handler);

      expect(capturedMessage, contains('DELETE'));
    });

    test('handles FormData body without throwing', () {
      final formData = FormData.fromMap(<String, dynamic>{'file': 'bytes'});
      final opts = _requestOptions(
        method: 'POST',
        path: '/upload',
        data: formData,
      );
      final handler = _FakeRequestHandler();

      expect(() => interceptor.onRequest(opts, handler), returnsNormally);
      expect(handler.wasCalled, isTrue);
    });

    test('handles null body without throwing', () {
      final opts = _requestOptions();
      final handler = _FakeRequestHandler();

      expect(() => interceptor.onRequest(opts, handler), returnsNormally);
      expect(handler.wasCalled, isTrue);
    });
  });

  // ── onResponse ───────────────────────────────────────────────────────────────

  group('onResponse', () {
    test('calls logger.info and forwards response to handler.next', () {
      final resp = _response(statusCode: 201, data: <String, dynamic>{'id': 1});
      final handler = _FakeResponseHandler();

      interceptor.onResponse(resp, handler);

      verify(
        () => mockLogger.info(any(), attributes: any(named: 'attributes')),
      ).called(1);
      expect(handler.wasCalled, isTrue);
      expect(handler.nextResponse, same(resp));
    });

    test('includes status code in the logged message', () {
      final resp = _response(statusCode: 404);
      final handler = _FakeResponseHandler();
      String? capturedMessage;

      when(
        () => mockLogger.info(any(), attributes: any(named: 'attributes')),
      ).thenAnswer((invocation) {
        capturedMessage = invocation.positionalArguments.first as String;
      });

      interceptor.onResponse(resp, handler);

      expect(capturedMessage, contains('404'));
    });

    test('handles response with null body without throwing', () {
      final resp = _response();
      final handler = _FakeResponseHandler();

      expect(() => interceptor.onResponse(resp, handler), returnsNormally);
      expect(handler.wasCalled, isTrue);
    });
  });

  // ── onError ──────────────────────────────────────────────────────────────────

  group('onError', () {
    test('calls logger.error and forwards error to handler.next', () {
      final err = _dioError(statusCode: 500);
      final handler = _FakeErrorHandler();

      interceptor.onError(err, handler);

      verify(
        () => mockLogger.error(
          any(),
          error: any(named: 'error'),
          stackTrace: any(named: 'stackTrace'),
          attributes: any(named: 'attributes'),
        ),
      ).called(1);
      expect(handler.wasCalled, isTrue);
      expect(handler.nextError, same(err));
    });

    test('forwards error when response is null (connection failure)', () {
      final err = _dioError();
      final handler = _FakeErrorHandler();

      interceptor.onError(err, handler);

      expect(handler.wasCalled, isTrue);
      expect(handler.nextError, same(err));
    });

    test('logs error with non-null status code attribute', () {
      final err = _dioError(statusCode: 403);
      final handler = _FakeErrorHandler();
      Map<String, Object?>? capturedAttrs;

      when(
        () => mockLogger.error(
          any(),
          error: any(named: 'error'),
          stackTrace: any(named: 'stackTrace'),
          attributes: any(named: 'attributes'),
        ),
      ).thenAnswer((invocation) {
        capturedAttrs =
            invocation.namedArguments[#attributes] as Map<String, Object?>?;
      });

      interceptor.onError(err, handler);

      expect(capturedAttrs?['http.status_code'], 403);
    });
  });
}
