import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:klozy/src/app/theme/app_config_change_notifier.dart';
import 'package:klozy/src/core/prefs/prefs.dart';
import 'package:mocktail/mocktail.dart';

class _MockPrefs extends Mock implements Prefs {}

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  late _MockPrefs prefs;

  setUp(() {
    prefs = _MockPrefs();
    when(() => prefs.isDark()).thenReturn(false);
  });

  tearDown(() {
    binding.platformDispatcher.clearLocaleTestValue();
  });

  group('AppConfigChangeNotifier — locale (device-driven, no UI picker)', () {
    test('supported device locale is used as-is', () {
      binding.platformDispatcher.localeTestValue = const Locale('es', 'ES');

      final config = AppConfigChangeNotifier(prefs);

      expect(config.locale, 'es');
      expect(Intl.defaultLocale, 'es');
    });

    test('unsupported device locale falls back to en', () {
      binding.platformDispatcher.localeTestValue = const Locale('de', 'DE');

      final config = AppConfigChangeNotifier(prefs);

      expect(config.locale, 'en');
      expect(Intl.defaultLocale, 'en');
    });

    test('never reads the persisted locale to decide the initial locale', () {
      binding.platformDispatcher.localeTestValue = const Locale('fr');

      AppConfigChangeNotifier(prefs);

      verifyNever(() => prefs.getLocale());
    });
  });

  group('AppConfigChangeNotifier.setLocale', () {
    test('updates locale and Intl.defaultLocale, persists via Prefs', () async {
      binding.platformDispatcher.localeTestValue = const Locale('en');
      when(() => prefs.setLocale(any())).thenAnswer((_) async {});
      final config = AppConfigChangeNotifier(prefs);

      await config.setLocale('fr');

      expect(config.locale, 'fr');
      expect(Intl.defaultLocale, 'fr');
      verify(() => prefs.setLocale('fr')).called(1);
    });

    test('no-op when languageCode is already the active locale', () async {
      binding.platformDispatcher.localeTestValue = const Locale('en');
      final config = AppConfigChangeNotifier(prefs);

      await config.setLocale('en');

      verifyNever(() => prefs.setLocale(any()));
    });
  });
}
