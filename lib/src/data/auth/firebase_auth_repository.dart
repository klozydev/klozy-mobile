import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/core/network/cache/session_cache.dart';
import 'package:klozy/src/domain/auth/auth_error_reason.dart';
import 'package:klozy/src/domain/auth/auth_exception.dart';
import 'package:klozy/src/domain/auth/auth_repository.dart';
import 'package:klozy/src/domain/auth/entity/auth_user.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

@LazySingleton(as: AuthRepository)
class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final MeRepository _meRepository;
  final SessionCache _cache;

  FirebaseAuthRepository(
    this._firebaseAuth,
    this._googleSignIn,
    this._meRepository,
    this._cache,
  );

  @override
  Stream<AuthUser?> authStateChanges() =>
      _firebaseAuth.authStateChanges().map(_mapNullable);

  @override
  AuthUser? get currentUser => _mapNullable(_firebaseAuth.currentUser);

  @override
  String? get currentUserId => _firebaseAuth.currentUser?.uid;

  @override
  bool get isAnonymous => _firebaseAuth.currentUser?.isAnonymous ?? false;

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
      throw AuthException(_emailReason(e), debugDetail: e.message);
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
      throw AuthException(_emailReason(e), debugDetail: e.message);
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_emailReason(e), debugDetail: e.message);
    }
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw const AuthException(AuthErrorReason.googleSignInFailed);
      }
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final cred = await _firebaseAuth.signInWithCredential(credential);
      return _map(cred.user!);
    } on GoogleSignInException catch (e) {
      throw AuthException(
        e.code == GoogleSignInExceptionCode.canceled
            ? AuthErrorReason.signInCancelled
            : AuthErrorReason.googleSignInFailed,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_emailReason(e), debugDetail: e.message);
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
            ? AuthErrorReason.signInCancelled
            : AuthErrorReason.appleSignInFailed,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_emailReason(e), debugDetail: e.message);
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
          completer.completeError(
            AuthException(_phoneReason(e), debugDetail: e.message),
          );
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
      throw AuthException(_phoneReason(e), debugDetail: e.message);
    }
  }

  @override
  Future<void> sendEmailUpdateVerification(String newEmail) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const AuthException(AuthErrorReason.reauthRequiredEmail);
    }
    try {
      await user.verifyBeforeUpdateEmail(newEmail.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_emailReason(e), debugDetail: e.message);
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const AuthException(AuthErrorReason.reauthRequiredPassword);
    }
    try {
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw AuthException(
          AuthErrorReason.reauthRequiredPassword,
          debugDetail: e.message,
        );
      }
      if (e.code == 'weak-password') {
        throw AuthException(
          AuthErrorReason.passwordTooWeak,
          debugDetail: e.message,
        );
      }
      throw AuthException(
        AuthErrorReason.passwordUpdateFailed,
        debugDetail: e.message,
      );
    }
  }

  @override
  Future<void> updatePhoneNumber({
    required String verificationId,
    required String smsCode,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const AuthException(AuthErrorReason.reauthRequiredPhone);
    }
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      await user.updatePhoneNumber(credential);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_phoneReason(e), debugDetail: e.message);
    }
  }

  @override
  Future<void> signOut() async {
    _meRepository.invalidate();
    _cache.clear();
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

  AuthErrorReason _emailReason(FirebaseAuthException e) => switch (e.code) {
    'invalid-email' => AuthErrorReason.invalidEmail,
    'user-disabled' => AuthErrorReason.userDisabled,
    'user-not-found' ||
    'wrong-password' ||
    'invalid-credential' => AuthErrorReason.wrongCredentials,
    'email-already-in-use' => AuthErrorReason.emailAlreadyInUse,
    'weak-password' => AuthErrorReason.weakPassword,
    'operation-not-allowed' => AuthErrorReason.operationNotAllowed,
    'requires-recent-login' => AuthErrorReason.requiresRecentLogin,
    'too-many-requests' => AuthErrorReason.tooManyRequests,
    'network-request-failed' => AuthErrorReason.networkRequestFailed,
    _ => AuthErrorReason.generic,
  };

  AuthErrorReason _phoneReason(FirebaseAuthException e) => switch (e.code) {
    'invalid-phone-number' => AuthErrorReason.invalidPhoneNumber,
    'invalid-verification-code' => AuthErrorReason.invalidVerificationCode,
    'session-expired' => AuthErrorReason.sessionExpired,
    'credential-already-in-use' || 'account-exists-with-different-credential' =>
      AuthErrorReason.phoneAlreadyInUse,
    'requires-recent-login' => AuthErrorReason.requiresRecentLogin,
    'too-many-requests' => AuthErrorReason.tooManyRequests,
    _ => AuthErrorReason.phoneVerificationFailed,
  };
}
