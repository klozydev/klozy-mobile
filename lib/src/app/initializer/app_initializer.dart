import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:klozy/src/core/prefs/prefs.dart';
import 'package:klozy/src/di/injection.dart';

/// Google web/server OAuth client (client_type 3 from google-services.json) —
/// the audience Firebase expects on the Google ID token.
const String _googleServerClientId =
    '1062855309544-439i7csdde2kvtg5ghcfu1fmneijbnp2.apps.googleusercontent.com';

Future<void> initialize() async {
  await GoogleSignIn.instance.initialize(serverClientId: _googleServerClientId);
  await configureDependencies();
  // Seed the API language header from the user's stored locale (falls back
  // to 'en') so a returning user's first request is already localized.
  Intl.defaultLocale = locator<Prefs>().getLocale();
}
