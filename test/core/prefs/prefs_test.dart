import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/core/prefs/prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ── getLocale ──────────────────────────────────────────────────────────────

  group('Prefs.getLocale', () {
    test('returns stored locale when set', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{'locale': 'fr'});
      final prefs = Prefs(await SharedPreferences.getInstance());
      expect(prefs.getLocale(), 'fr');
    });

    test('returns en as default when no locale stored', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = Prefs(await SharedPreferences.getInstance());
      expect(prefs.getLocale(), 'en');
    });
  });

  // ── setLocale ──────────────────────────────────────────────────────────────

  group('Prefs.setLocale', () {
    test('persists locale to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final sp = await SharedPreferences.getInstance();
      final prefs = Prefs(sp);

      await prefs.setLocale('es');

      expect(sp.getString('locale'), 'es');
    });

    test('overwrites previously stored locale', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{'locale': 'fr'});
      final sp = await SharedPreferences.getInstance();
      final prefs = Prefs(sp);

      await prefs.setLocale('de');

      expect(sp.getString('locale'), 'de');
      expect(prefs.getLocale(), 'de');
    });
  });

  // ── isDark ─────────────────────────────────────────────────────────────────

  group('Prefs.isDark', () {
    test('returns true when stored isDark is true', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{'isDark': true});
      final prefs = Prefs(await SharedPreferences.getInstance());
      expect(prefs.isDark(), isTrue);
    });

    test('returns false when stored isDark is false', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{'isDark': false});
      final prefs = Prefs(await SharedPreferences.getInstance());
      expect(prefs.isDark(), isFalse);
    });

    test(
      'falls back to platform brightness (light) when isDark not stored',
      () async {
        SharedPreferences.setMockInitialValues(<String, Object>{});
        final prefs = Prefs(await SharedPreferences.getInstance());
        // The test environment reports Brightness.light by default.
        final platformIsDark =
            WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;
        expect(prefs.isDark(), platformIsDark);
      },
    );
  });
}
