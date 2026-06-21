import 'package:dio/dio.dart';

/// Coarse, user-facing error categories. BLoCs map any thrown error to one of
/// these via [AppErrorType.fromException]; widgets render [title]/[message].
enum AppErrorType {
  network,
  timeout,
  unauthorized,
  notFound,
  server,
  unknown;

  static AppErrorType fromException(Object error) {
    if (error is AppErrorType) return error;
    if (error is DioException) return _fromDio(error);
    return AppErrorType.unknown;
  }

  static AppErrorType _fromDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppErrorType.timeout;
      case DioExceptionType.connectionError:
        return AppErrorType.network;
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode ?? 0;
        if (status == 401 || status == 403) return AppErrorType.unauthorized;
        if (status == 404) return AppErrorType.notFound;
        if (status >= 500) return AppErrorType.server;
        return AppErrorType.unknown;
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return AppErrorType.network;
    }
  }

  /// The human-readable `message` field from a backend error body (e.g. a 409
  /// "Some items are no longer available …"), or null if absent.
  static String? serverMessage(Object error) {
    if (error is DioException) {
      final dynamic data = error.response?.data;
      if (data is Map && data['message'] is String) {
        return data['message'] as String;
      }
    }
    return null;
  }

  String get title => switch (this) {
    AppErrorType.network => 'No connection',
    AppErrorType.timeout => 'Took too long',
    AppErrorType.unauthorized => 'Session expired',
    AppErrorType.notFound => 'Not found',
    AppErrorType.server => 'Something went wrong',
    AppErrorType.unknown => 'Something went wrong',
  };

  String get message => switch (this) {
    AppErrorType.network => 'Check your internet connection and try again.',
    AppErrorType.timeout => 'The request timed out. Please try again.',
    AppErrorType.unauthorized => 'Please sign in again to continue.',
    AppErrorType.notFound => "We couldn't find what you were looking for.",
    AppErrorType.server => 'Our servers had a hiccup. Please try again.',
    AppErrorType.unknown => 'An unexpected error occurred. Please try again.',
  };
}
