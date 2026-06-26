import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/core/network/base_url/base_url.dart';
import 'package:klozy/src/core/network/interceptors/authentication_interceptor.dart';
import 'package:mocktail/mocktail.dart';

// ── Fakes / Mocks ─────────────────────────────────────────────────────────────

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockUser extends Mock implements User {}

class _MockBaseUrl extends Mock implements BaseUrl {}

/// A [RequestInterceptorHandler] that captures what was called on it.
class _FakeRequestHandler extends Fake implements RequestInterceptorHandler {
  RequestOptions? nextOptions;
  DioException? rejectError;
  bool wasCalled = false;

  @override
  void next(RequestOptions options) {
    wasCalled = true;
    nextOptions = options;
  }

  @override
  void reject(DioException err, [bool callFollowingErrorInterceptor = false]) {
    wasCalled = true;
    rejectError = err;
  }
}

/// A [ErrorInterceptorHandler] that captures what was called on it.
class _FakeErrorHandler extends Fake implements ErrorInterceptorHandler {
  DioException? nextError;
  Response<dynamic>? resolvedResponse;
  bool wasCalled = false;

  @override
  void next(DioException err) {
    wasCalled = true;
    nextError = err;
  }

  @override
  void resolve(
    Response<dynamic> response, [
    bool callFollowingResponseInterceptor = false,
  ]) {
    wasCalled = true;
    resolvedResponse = response;
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

RequestOptions _options({String path = '/test'}) => RequestOptions(path: path);

DioException _dioError({int statusCode = 401, RequestOptions? options}) =>
    DioException(
      requestOptions: options ?? _options(),
      response: Response<dynamic>(
        requestOptions: options ?? _options(),
        statusCode: statusCode,
      ),
      type: DioExceptionType.badResponse,
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late _MockFirebaseAuth mockAuth;
  late _MockUser mockUser;
  late _MockBaseUrl mockBaseUrl;
  late AuthenticationInterceptor interceptor;

  setUp(() {
    mockAuth = _MockFirebaseAuth();
    mockUser = _MockUser();
    mockBaseUrl = _MockBaseUrl();
    when(() => mockBaseUrl.baseUrl).thenReturn('https://api.klozy.com/');
    interceptor = AuthenticationInterceptor(mockAuth, mockBaseUrl);
  });

  // ── onRequest ───────────────────────────────────────────────────────────────

  group('onRequest', () {
    test('attaches Bearer header when getIdToken succeeds', () async {
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.getIdToken(any())).thenAnswer((_) async => 'tok123');

      final handler = _FakeRequestHandler();
      await interceptor.onRequest(_options(), handler);

      expect(handler.wasCalled, isTrue);
      expect(handler.nextOptions!.headers['Authorization'], 'Bearer tok123');
    });

    test(
      'calls handler.next without header when no user is signed in',
      () async {
        when(() => mockAuth.currentUser).thenReturn(null);

        final handler = _FakeRequestHandler();
        await interceptor.onRequest(_options(), handler);

        expect(handler.wasCalled, isTrue);
        expect(
          handler.nextOptions!.headers.containsKey('Authorization'),
          isFalse,
        );
      },
    );

    test('calls handler.next without header when getIdToken throws', () async {
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(
        () => mockUser.getIdToken(any()),
      ).thenThrow(Exception('network error'));

      final handler = _FakeRequestHandler();
      await interceptor.onRequest(_options(), handler);

      // Queue must NOT stall — handler.next() must always be reached.
      expect(handler.wasCalled, isTrue);
      expect(
        handler.nextOptions!.headers.containsKey('Authorization'),
        isFalse,
      );
    });

    test(
      'calls handler.next without header when getIdToken returns null',
      () async {
        when(() => mockAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.getIdToken(any())).thenAnswer((_) async => null);

        final handler = _FakeRequestHandler();
        await interceptor.onRequest(_options(), handler);

        expect(handler.wasCalled, isTrue);
        expect(
          handler.nextOptions!.headers.containsKey('Authorization'),
          isFalse,
        );
      },
    );

    test(
      'calls handler.next without header when getIdToken returns empty string',
      () async {
        when(() => mockAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.getIdToken(any())).thenAnswer((_) async => '');

        final handler = _FakeRequestHandler();
        await interceptor.onRequest(_options(), handler);

        expect(handler.wasCalled, isTrue);
        expect(
          handler.nextOptions!.headers.containsKey('Authorization'),
          isFalse,
        );
      },
    );
  });

  // ── onError ─────────────────────────────────────────────────────────────────

  group('onError', () {
    test('passes non-401 errors through unchanged', () async {
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      final error = _dioError(statusCode: 500);

      final handler = _FakeErrorHandler();
      await interceptor.onError(error, handler);

      expect(handler.wasCalled, isTrue);
      expect(handler.nextError?.response?.statusCode, 500);
    });

    test('passes 401 through when already retried', () async {
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      final options = _options()..extra['retried'] = true;
      final error = _dioError(statusCode: 401, options: options);

      final handler = _FakeErrorHandler();
      await interceptor.onError(error, handler);

      expect(handler.wasCalled, isTrue);
      expect(handler.nextError?.response?.statusCode, 401);
      // Force-refresh should NOT be attempted.
      verifyNever(() => mockUser.getIdToken(true));
    });

    test('passes 401 through when no user is signed in', () async {
      when(() => mockAuth.currentUser).thenReturn(null);
      final error = _dioError(statusCode: 401);

      final handler = _FakeErrorHandler();
      await interceptor.onError(error, handler);

      expect(handler.wasCalled, isTrue);
      expect(handler.nextError?.response?.statusCode, 401);
    });

    test('passes 401 through when force-refresh returns null', () async {
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.getIdToken(true)).thenAnswer((_) async => null);
      final error = _dioError(statusCode: 401);

      final handler = _FakeErrorHandler();
      await interceptor.onError(error, handler);

      expect(handler.wasCalled, isTrue);
      expect(handler.nextError?.response?.statusCode, 401);
    });

    test(
      'passes original 401 through when force-refresh getIdToken throws (queue must not stall)',
      () async {
        when(() => mockAuth.currentUser).thenReturn(mockUser);
        when(
          () => mockUser.getIdToken(true),
        ).thenThrow(Exception('revoked session'));
        final error = _dioError(statusCode: 401);

        final handler = _FakeErrorHandler();
        await interceptor.onError(error, handler);

        // _idToken swallows the throw and returns null → handler.next(err)
        expect(handler.wasCalled, isTrue);
        expect(handler.nextError?.response?.statusCode, 401);
      },
    );
  });
}
