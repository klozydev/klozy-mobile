import 'package:flutter/widgets.dart';

/// A language the app UI can be displayed in. [name] is the endonym (the
/// language's own name) so each entry reads natively in the picker regardless
/// of the currently active locale.
@immutable
class AppLanguage {
  const AppLanguage({required this.code, required this.name});

  final String code;
  final String name;

  Locale get locale => Locale(code);
}

/// The 12 locales shipped with Klozy. Order mirrors the reference app's
/// language list. Keep in sync with the `app_<code>.arb` files in `lib/l10n/`
/// and `AppLocalizations.supportedLocales`.
const List<AppLanguage> kAppLanguages = <AppLanguage>[
  AppLanguage(code: 'en', name: 'English'),
  AppLanguage(code: 'ar', name: 'العربية'),
  AppLanguage(code: 'fr', name: 'Français'),
  AppLanguage(code: 'es', name: 'Español'),
  AppLanguage(code: 'pt', name: 'Português'),
  AppLanguage(code: 'ru', name: 'Русский'),
  AppLanguage(code: 'hi', name: 'हिन्दी'),
  AppLanguage(code: 'ml', name: 'മലയാളം'),
  AppLanguage(code: 'ur', name: 'اردو'),
  AppLanguage(code: 'fa', name: 'فارسی'),
  AppLanguage(code: 'fil', name: 'Filipino'),
  AppLanguage(code: 'kk', name: 'Қазақша'),
];

/// Resolves [deviceLanguageCode] (e.g. `platformDispatcher.locale.languageCode`)
/// to one of [kAppLanguages]' codes, falling back to `'en'` when the device
/// language isn't shipped.
///
/// There is no in-app language picker — the UI language is driven purely by
/// the device language, so this is the single source of truth for the app's
/// active locale (see `AppConfigChangeNotifier`).
String resolveSupportedLocaleCode(String deviceLanguageCode) {
  final Iterable<String> supportedCodes = kAppLanguages.map(
    (AppLanguage language) => language.code,
  );
  return supportedCodes.contains(deviceLanguageCode)
      ? deviceLanguageCode
      : 'en';
}
