import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';

/// Provides Firebase / Google singletons for the auth layer.
///
/// `GoogleSignIn` v7 is a singleton that must be `initialize()`d once before
/// use — that happens in `AppInitializer`. Here we just expose the instance.
@module
abstract class FirebaseModule {
  @lazySingleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  @lazySingleton
  GoogleSignIn get googleSignIn => GoogleSignIn.instance;

  @lazySingleton
  FirebaseMessaging get firebaseMessaging => FirebaseMessaging.instance;
}
