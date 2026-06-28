import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/core/observability/no_op_app_logger.dart';

void main() {
  late NoOpAppLogger logger;

  setUp(() {
    logger = NoOpAppLogger();
  });

  // Each method must not throw under any combination of arguments.

  group('NoOpAppLogger.debug', () {
    test('does not throw with message only', () {
      logger.debug('debug message');
    });

    test('does not throw with error and stackTrace', () {
      logger.debug(
        'debug with context',
        error: Exception('oops'),
        stackTrace: StackTrace.current,
      );
    });

    test('does not throw with attributes', () {
      logger.debug(
        'debug with attrs',
        attributes: <String, Object?>{'key': 'value', 'count': 42},
      );
    });
  });

  group('NoOpAppLogger.info', () {
    test('does not throw with message only', () {
      logger.info('info message');
    });

    test('does not throw with error and stackTrace', () {
      logger.info(
        'info with context',
        error: Exception('something'),
        stackTrace: StackTrace.current,
      );
    });

    test('does not throw with attributes', () {
      logger.info(
        'info with attrs',
        attributes: <String, Object?>{'user': 'u1'},
      );
    });
  });

  group('NoOpAppLogger.warn', () {
    test('does not throw with message only', () {
      logger.warn('warn message');
    });

    test('does not throw with error and stackTrace', () {
      logger.warn(
        'warn with context',
        error: StateError('bad state'),
        stackTrace: StackTrace.current,
      );
    });

    test('does not throw with attributes', () {
      logger.warn(
        'warn with attrs',
        attributes: <String, Object?>{'flag': true},
      );
    });
  });

  group('NoOpAppLogger.error', () {
    test('does not throw with message only', () {
      logger.error('error message');
    });

    test('does not throw with error and stackTrace', () {
      logger.error(
        'error with context',
        error: Exception('critical'),
        stackTrace: StackTrace.current,
      );
    });

    test('does not throw with attributes', () {
      logger.error(
        'error with attrs',
        attributes: <String, Object?>{'severity': 'high', 'code': 500},
      );
    });

    test('does not throw with all optional params null', () {
      logger.error('bare error');
    });
  });
}
