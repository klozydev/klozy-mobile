import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:klozy/src/core/prefs/prefs.dart';

@lazySingleton
class AppConfigChangeNotifier extends ChangeNotifier {
  final Prefs _prefs;
  late bool _isDark;
  late String _locale;

  bool get isDark => _isDark;

  String get locale => _locale;

  AppConfigChangeNotifier(this._prefs) {
    _isDark =
        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
        Brightness.dark;
    _locale = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    getBrightness();
    getLocale();
  }

  void getBrightness() {
    _isDark = _prefs.isDark();
    notifyListeners();
  }

  void getLocale() {
    _locale = _prefs.getLocale();
    // Keep the API language header (read from Intl.defaultLocale by
    // DefaultInterceptor) in sync with the locale actually in use.
    Intl.defaultLocale = _locale;
    notifyListeners();
  }

  Future<void> setLocale(String languageCode) async {
    if (_locale == languageCode) {
      return;
    }
    await _prefs.setLocale(languageCode);
    _locale = languageCode;
    Intl.defaultLocale = languageCode;
    notifyListeners();
  }
}
