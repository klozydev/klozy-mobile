import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:klozy/src/core/l10n/app_language.dart';
import 'package:klozy/src/di/injection.dart';

/// Google web/server OAuth client (client_type 3 from google-services.json) —
/// the audience Firebase expects on the Google ID token.
const String _googleServerClientId =
    '1062855309544-439i7csdde2kvtg5ghcfu1fmneijbnp2.apps.googleusercontent.com';

Future<void> initialize() async {
  await GoogleSignIn.instance.initialize(serverClientId: _googleServerClientId);
  await configureDependencies();
  // Seed the API language header from the device language (there is no
  // in-app language picker — the UI language is purely device-driven) so the
  // very first request, before AppConfigChangeNotifier is built, is already
  // localized.
  Intl.defaultLocale = resolveSupportedLocaleCode(
    WidgetsBinding.instance.platformDispatcher.locale.languageCode,
  );
}
