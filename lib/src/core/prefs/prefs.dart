import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@Injectable()
class Prefs {
  final SharedPreferences _sharedPreferences;

  const Prefs(this._sharedPreferences);

  bool isDark() {
    final Brightness brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;
    return _sharedPreferences.getBool('isDark') ?? isDarkMode;
  }

  String getLocale() {
    return _sharedPreferences.getString('locale') ?? 'en';
  }
}
