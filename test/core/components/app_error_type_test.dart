import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/core/components/app_error_type.dart';

DioException makeDio(DioExceptionType type, {Response<dynamic>? response}) {
  return DioException(
    requestOptions: RequestOptions(path: ''),
    type: type,
    response: response,
  );
}

Response<dynamic> makeResponse(int statusCode, {dynamic data}) {
  return Response<dynamic>(
    requestOptions: RequestOptions(path: ''),
    statusCode: statusCode,
    data: data,
  );
}

void main() {
  // ── fromException ──────────────────────────────────────────────────────────

  group('AppErrorType.fromException', () {
    group('identity – AppErrorType input', () {
      for (final type in AppErrorType.values) {
        test('returns $type unchanged', () {
          expect(AppErrorType.fromException(type), type);
        });
      }
    });

    test('returns unknown for generic Exception', () {
      expect(
        AppErrorType.fromException(Exception('oops')),
        AppErrorType.unknown,
      );
    });

    test('returns unknown for arbitrary object', () {
      expect(AppErrorType.fromException('some string'), AppErrorType.unknown);
    });

    // ── Dio timeout types ────────────────────────────────────────────────────

    test('connectionTimeout → timeout', () {
      expect(
        AppErrorType.fromException(makeDio(DioExceptionType.connectionTimeout)),
        AppErrorType.timeout,
      );
    });

    test('sendTimeout → timeout', () {
      expect(
        AppErrorType.fromException(makeDio(DioExceptionType.sendTimeout)),
        AppErrorType.timeout,
      );
    });

    test('receiveTimeout → timeout', () {
      expect(
        AppErrorType.fromException(makeDio(DioExceptionType.receiveTimeout)),
        AppErrorType.timeout,
      );
    });

    // ── Dio network types ────────────────────────────────────────────────────

    test('connectionError → network', () {
      expect(
        AppErrorType.fromException(makeDio(DioExceptionType.connectionError)),
        AppErrorType.network,
      );
    });

    test('badCertificate → network', () {
      expect(
        AppErrorType.fromException(makeDio(DioExceptionType.badCertificate)),
        AppErrorType.network,
      );
    });

    test('cancel → network', () {
      expect(
        AppErrorType.fromException(makeDio(DioExceptionType.cancel)),
        AppErrorType.network,
      );
    });

    test('unknown Dio type → network', () {
      expect(
        AppErrorType.fromException(makeDio(DioExceptionType.unknown)),
        AppErrorType.network,
      );
    });

    // ── badResponse – HTTP status mapping ────────────────────────────────────

    group('badResponse', () {
      test('401 → unauthorized', () {
        expect(
          AppErrorType.fromException(
            makeDio(DioExceptionType.badResponse, response: makeResponse(401)),
          ),
          AppErrorType.unauthorized,
        );
      });

      test('403 → unauthorized', () {
        expect(
          AppErrorType.fromException(
            makeDio(DioExceptionType.badResponse, response: makeResponse(403)),
          ),
          AppErrorType.unauthorized,
        );
      });

      test('404 → notFound', () {
        expect(
          AppErrorType.fromException(
            makeDio(DioExceptionType.badResponse, response: makeResponse(404)),
          ),
          AppErrorType.notFound,
        );
      });

      test('500 → server', () {
        expect(
          AppErrorType.fromException(
            makeDio(DioExceptionType.badResponse, response: makeResponse(500)),
          ),
          AppErrorType.server,
        );
      });

      test('503 → server', () {
        expect(
          AppErrorType.fromException(
            makeDio(DioExceptionType.badResponse, response: makeResponse(503)),
          ),
          AppErrorType.server,
        );
      });

      test('400 → unknown', () {
        expect(
          AppErrorType.fromException(
            makeDio(DioExceptionType.badResponse, response: makeResponse(400)),
          ),
          AppErrorType.unknown,
        );
      });

      test('422 → unknown', () {
        expect(
          AppErrorType.fromException(
            makeDio(DioExceptionType.badResponse, response: makeResponse(422)),
          ),
          AppErrorType.unknown,
        );
      });

      test('null response (no statusCode) → unknown', () {
        expect(
          AppErrorType.fromException(makeDio(DioExceptionType.badResponse)),
          AppErrorType.unknown,
        );
      });
    });
  });

  // ── serverMessage ──────────────────────────────────────────────────────────

  group('AppErrorType.serverMessage', () {
    test('returns null for non-Dio error', () {
      expect(AppErrorType.serverMessage(Exception('x')), isNull);
    });

    test('returns null when DioException has no response', () {
      expect(
        AppErrorType.serverMessage(makeDio(DioExceptionType.connectionError)),
        isNull,
      );
    });

    test('returns null when response data is not a Map', () {
      expect(
        AppErrorType.serverMessage(
          makeDio(
            DioExceptionType.badResponse,
            response: makeResponse(400, data: 'plain string'),
          ),
        ),
        isNull,
      );
    });

    test('returns null when message key is missing from Map', () {
      expect(
        AppErrorType.serverMessage(
          makeDio(
            DioExceptionType.badResponse,
            response: makeResponse(400, data: <String, dynamic>{'code': 42}),
          ),
        ),
        isNull,
      );
    });

    test('returns null when message value is not a String', () {
      expect(
        AppErrorType.serverMessage(
          makeDio(
            DioExceptionType.badResponse,
            response: makeResponse(
              400,
              data: <String, dynamic>{'message': 123},
            ),
          ),
        ),
        isNull,
      );
    });

    test('returns message string when present in response data Map', () {
      expect(
        AppErrorType.serverMessage(
          makeDio(
            DioExceptionType.badResponse,
            response: makeResponse(
              409,
              data: <String, dynamic>{'message': 'Some items are unavailable'},
            ),
          ),
        ),
        'Some items are unavailable',
      );
    });
  });

  // ── title ──────────────────────────────────────────────────────────────────

  group('AppErrorType.title', () {
    test('network title', () {
      expect(AppErrorType.network.title, 'No connection');
    });

    test('timeout title', () {
      expect(AppErrorType.timeout.title, 'Took too long');
    });

    test('unauthorized title', () {
      expect(AppErrorType.unauthorized.title, 'Session expired');
    });

    test('notFound title', () {
      expect(AppErrorType.notFound.title, 'Not found');
    });

    test('server title', () {
      expect(AppErrorType.server.title, 'Something went wrong');
    });

    test('unknown title', () {
      expect(AppErrorType.unknown.title, 'Something went wrong');
    });
  });

  // ── message ────────────────────────────────────────────────────────────────

  group('AppErrorType.message', () {
    test('network message', () {
      expect(
        AppErrorType.network.message,
        'Check your internet connection and try again.',
      );
    });

    test('timeout message', () {
      expect(
        AppErrorType.timeout.message,
        'The request timed out. Please try again.',
      );
    });

    test('unauthorized message', () {
      expect(
        AppErrorType.unauthorized.message,
        'Please sign in again to continue.',
      );
    });

    test('notFound message', () {
      expect(
        AppErrorType.notFound.message,
        "We couldn't find what you were looking for.",
      );
    });

    test('server message', () {
      expect(
        AppErrorType.server.message,
        'Our servers had a hiccup. Please try again.',
      );
    });

    test('unknown message', () {
      expect(
        AppErrorType.unknown.message,
        'An unexpected error occurred. Please try again.',
      );
    });
  });
}
