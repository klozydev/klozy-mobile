import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/di/injection.config.dart';

final locator = GetIt.instance;

@InjectableInit(throwOnMissingDependencies: true, includeMicroPackages: false)
Future<void> configureDependencies() => locator.init();
