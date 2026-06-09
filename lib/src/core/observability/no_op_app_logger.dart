import 'package:flutter/foundation.dart';
import 'package:klozy/src/core/observability/app_logger.dart';

class NoOpAppLogger implements AppLogger {
  @override
  void debug(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> attributes = const {},
  }) {
    _print('DEBUG', message, error, stackTrace);
  }

  @override
  void info(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> attributes = const {},
  }) {
    _print('INFO', message, error, stackTrace);
  }

  @override
  void warn(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> attributes = const {},
  }) {
    _print('WARN', message, error, stackTrace);
  }

  @override
  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> attributes = const {},
  }) {
    _print('ERROR', message, error, stackTrace);
  }

  void _print(
    String level,
    String message,
    Object? error,
    StackTrace? stackTrace,
  ) {
    if (!kDebugMode) {
      return;
    }
    final buffer = StringBuffer('[$level] $message');
    if (error != null) {
      buffer.write(' | error: $error');
    }
    if (stackTrace != null) {
      buffer.write('\n$stackTrace');
    }
    debugPrint(buffer.toString());
  }
}
