import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:klozy/firebase_options.dart';
import 'package:klozy/src/app/initializer/app_initializer.dart';
import 'package:klozy/src/app/widget/app.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Required by the chat island, which renders strings via easy_localization
  // `.tr()`. Coexists with mobile's gen-l10n (`context.l10N`).
  await EasyLocalization.ensureInitialized();

  await initialize();
  runApp(
    EasyLocalization(
      supportedLocales: const <Locale>[Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const App(),
    ),
  );
  FlutterNativeSplash.remove();
}
