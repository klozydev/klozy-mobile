import 'package:injectable/injectable.dart';
import 'package:klozy/src/core/observability/app_logger.dart';
import 'package:klozy/src/core/observability/no_op_app_logger.dart';

@module
abstract class ObservabilityModule {
  @lazySingleton
  AppLogger getAppLogger() => NoOpAppLogger();
}
