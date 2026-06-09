import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/domain/auth/auth_exception.dart';
import 'package:klozy/src/domain/auth/auth_repository.dart';
import 'package:klozy/src/domain/auth/entity/auth_user.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

@LazySingleton(as: AuthRepository)
class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthRepository(this._firebaseAuth, this._googleSignIn);

  @override
  Stream<AuthUser?> authStateChanges() =>
      _firebaseAuth.authStateChanges().map(_mapNullable);

  @override
  AuthUser? get currentUser => _mapNullable(_firebaseAuth.currentUser);

  @override
  Future<AuthUser> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return _map(cred.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_emailMessage(e));
    }
  }

  @override
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return _map(cred.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_emailMessage(e));
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_emailMessage(e));
    }
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw const AuthException('Google sign-in failed. Please try again.');
      }
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final cred = await _firebaseAuth.signInWithCredential(credential);
      return _map(cred.user!);
    } on GoogleSignInException catch (e) {
      throw AuthException(
        e.code == GoogleSignInExceptionCode.canceled
            ? 'Sign-in cancelled.'
            : 'Google sign-in failed. Please try again.',
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_emailMessage(e));
    }
  }

  @override
  Future<AuthUser> signInWithApple() async {
    try {
      final rawNonce = _generateNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
        accessToken: appleCredential.authorizationCode,
      );
      final cred = await _firebaseAuth.signInWithCredential(oauthCredential);
      return _map(cred.user!);
    } on SignInWithAppleAuthorizationException catch (e) {
      throw AuthException(
        e.code == AuthorizationErrorCode.canceled
            ? 'Sign-in cancelled.'
            : 'Apple sign-in failed. Please try again.',
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_emailMessage(e));
    }
  }

  @override
  Future<PhoneVerification> startPhoneVerification(String phoneNumber) async {
    final completer = Completer<PhoneVerification>();
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (_) {},
      verificationFailed: (e) {
        if (!completer.isCompleted) {
          completer.completeError(AuthException(_phoneMessage(e)));
        }
      },
      codeSent: (verificationId, resendToken) {
        if (!completer.isCompleted) {
          completer.complete(
            PhoneVerification(
              verificationId: verificationId,
              resendToken: resendToken,
            ),
          );
        }
      },
      codeAutoRetrievalTimeout: (_) {},
    );
    return completer.future;
  }

  @override
  Future<AuthUser> confirmPhoneCode({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final cred = await _firebaseAuth.signInWithCredential(credential);
      return _map(cred.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_phoneMessage(e));
    }
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  // ── Mapping ───────────────────────────────────────────────────────────────

  AuthUser? _mapNullable(User? user) => user == null ? null : _map(user);

  AuthUser _map(User user) => AuthUser(
    uid: user.uid,
    email: user.email,
    phoneNumber: user.phoneNumber,
    displayName: user.displayName,
    photoUrl: user.photoURL,
    emailVerified: user.emailVerified,
  );

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List<String>.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _emailMessage(FirebaseAuthException e) => switch (e.code) {
    'invalid-email' => 'That email address looks invalid.',
    'user-disabled' => 'This account has been disabled.',
    'user-not-found' ||
    'wrong-password' ||
    'invalid-credential' => 'Wrong email or password.',
    'email-already-in-use' => 'An account already exists for that email.',
    'weak-password' => 'Choose a stronger password (at least 8 characters).',
    'operation-not-allowed' => 'This sign-in method is not enabled.',
    'too-many-requests' => 'Too many attempts. Please try again later.',
    'network-request-failed' => 'Network error. Check your connection.',
    _ => 'Something went wrong. Please try again.',
  };

  String _phoneMessage(FirebaseAuthException e) => switch (e.code) {
    'invalid-phone-number' => 'That phone number looks invalid.',
    'invalid-verification-code' => 'That code is incorrect.',
    'session-expired' => 'The code expired. Request a new one.',
    'too-many-requests' => 'Too many attempts. Please try again later.',
    _ => 'Phone verification failed. Please try again.',
  };
}
