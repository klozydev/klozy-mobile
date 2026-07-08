import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/core/l10n/app_language.dart';

void main() {
  group('resolveSupportedLocaleCode', () {
    test('returns the device code when it is supported', () {
      expect(resolveSupportedLocaleCode('es'), 'es');
    });

    test('returns en for an unsupported device code', () {
      expect(resolveSupportedLocaleCode('de'), 'en');
    });

    test('returns en for an empty device code', () {
      expect(resolveSupportedLocaleCode(''), 'en');
    });

    test('every kAppLanguages code resolves to itself', () {
      for (final AppLanguage language in kAppLanguages) {
        expect(resolveSupportedLocaleCode(language.code), language.code);
      }
    });
  });
}
