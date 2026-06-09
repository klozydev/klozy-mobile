import 'package:event_bus/event_bus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'
    as flutter_secure_storage;
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@module
abstract class AppModule {
  @lazySingleton
  EventBus getEventBus() => EventBus();

  @lazySingleton
  flutter_secure_storage.FlutterSecureStorage getFlutterSecureStorage() {
    const aOptions = flutter_secure_storage.AndroidOptions(
      encryptedSharedPreferences: true,
    );
    return const flutter_secure_storage.FlutterSecureStorage(
      aOptions: aOptions,
    );
  }

  @preResolve
  Future<SharedPreferences> getSharedPreferences() {
    return SharedPreferences.getInstance();
  }
}
