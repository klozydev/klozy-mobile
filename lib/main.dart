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
  await initialize();
  runApp(const App());
  FlutterNativeSplash.remove();
}
