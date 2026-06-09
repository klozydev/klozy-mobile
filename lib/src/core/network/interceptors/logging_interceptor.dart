import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/core/observability/app_logger.dart';

@injectable
class LoggingInterceptor extends Interceptor {
  LoggingInterceptor(this._logger);

  final AppLogger _logger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final method = options.method;
    final uri = options.uri.toString();

    _logger.info(
      'API → $method $uri',
      attributes: {
        'http.method': method,
        'http.url': uri,
        'http.request.headers': _stringifyHeaders(options.headers),
        'http.request.body': _stringifyBody(options.data),
      },
    );

    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final request = response.requestOptions;
    final method = request.method;
    final uri = request.uri.toString();
    final status = response.statusCode;

    _logger.info(
      'API ← $method $uri ($status)',
      attributes: {
        'http.method': method,
        'http.url': uri,
        'http.status_code': status,
        'http.request.body': _stringifyBody(request.data),
        'http.response.headers': _stringifyHeaders(
          response.headers.map.map(
            (key, value) => MapEntry(key, value.join(', ')),
          ),
        ),
        'http.response.body': _stringifyBody(response.data),
      },
    );

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final request = err.requestOptions;
    final response = err.response;
    final method = request.method;
    final uri = request.uri.toString();
    final status = response?.statusCode;

    log(
      '$method $uri '
      '→ ${status ?? 'NO RESPONSE'}: '
      '${err.message}\n'
      'Response: ${response?.data}',
      name: 'API',
      error: err,
    );

    _logger.error(
      'API ✗ $method $uri (${status ?? 'NO RESPONSE'})',
      error: err,
      stackTrace: err.stackTrace,
      attributes: {
        'http.method': method,
        'http.url': uri,
        'http.status_code': status,
        'http.request.headers': _stringifyHeaders(request.headers),
        'http.request.body': _stringifyBody(request.data),
        'http.response.body': _stringifyBody(response?.data),
        'error.type': err.type.name,
        'error.message': err.message,
      },
    );

    handler.next(err);
  }

  String _stringifyBody(Object? data) {
    if (data == null) return '';
    if (data is FormData) {
      final fields = data.fields.map((e) => '${e.key}=${e.value}').join('&');
      final files = data.files.map((e) => e.key).join(',');
      return 'FormData(fields: $fields, files: $files)';
    }
    return data.toString();
  }

  String _stringifyHeaders(Map<String, dynamic> headers) {
    return headers.entries.map((e) => '${e.key}: ${e.value}').join('\n');
  }
}
