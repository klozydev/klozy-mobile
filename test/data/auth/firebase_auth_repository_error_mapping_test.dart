import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:klozy/src/core/network/cache/session_cache.dart';
import 'package:klozy/src/data/auth/firebase_auth_repository.dart';
import 'package:klozy/src/domain/auth/auth_error_reason.dart';
import 'package:klozy/src/domain/auth/auth_exception.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockGoogleSignIn extends Mock implements GoogleSignIn {}

class _MockMeRepository extends Mock implements MeRepository {}

class _MockUser extends Mock implements User {}

// ignore: avoid_implementing_value_types
class _MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class _FakeAuthCredential extends Fake implements AuthCredential {}

class _FakePhoneAuthCredential extends Fake implements PhoneAuthCredential {}

/// Builds a [FirebaseAuthException] with the given [code].
///
/// The real constructor is `@protected` (library-private in intent), but
/// Dart only enforces that as an analyzer lint on `lib/` sources — it is the
/// standard way to fabricate SDK exceptions for datasource unit tests.
FirebaseAuthException _fbException(String code) =>
    FirebaseAuthException(code: code, message: 'debug-$code');

Matcher _throwsReason(AuthErrorReason reason) =>
    throwsA(isA<AuthException>().having((e) => e.reason, 'reason', reason));

void main() {
  late _MockFirebaseAuth mockAuth;
  late _MockGoogleSignIn mockGoogleSignIn;
  late _MockMeRepository mockMe;
  late FirebaseAuthRepository repo;

  setUpAll(() {
    registerFallbackValue(_FakeAuthCredential());
    registerFallbackValue(_FakePhoneAuthCredential());
  });

  setUp(() {
    mockAuth = _MockFirebaseAuth();
    mockGoogleSignIn = _MockGoogleSignIn();
    mockMe = _MockMeRepository();
    repo = FirebaseAuthRepository(
      mockAuth,
      mockGoogleSignIn,
      mockMe,
      SessionCache(),
    );
  });

  // ── email/password reason mapping (shared table across 3 entry points) ────

  const emailCases = <String, AuthErrorReason>{
    'invalid-email': AuthErrorReason.invalidEmail,
    'user-disabled': AuthErrorReason.userDisabled,
    'user-not-found': AuthErrorReason.wrongCredentials,
    'wrong-password': AuthErrorReason.wrongCredentials,
    'invalid-credential': AuthErrorReason.wrongCredentials,
    'email-already-in-use': AuthErrorReason.emailAlreadyInUse,
    'weak-password': AuthErrorReason.weakPassword,
    'operation-not-allowed': AuthErrorReason.operationNotAllowed,
    'requires-recent-login': AuthErrorReason.requiresRecentLogin,
    'too-many-requests': AuthErrorReason.tooManyRequests,
    'network-request-failed': AuthErrorReason.networkRequestFailed,
    'some-unmapped-code': AuthErrorReason.generic,
  };

  group('signUpWithEmail — reason mapping', () {
    for (final entry in emailCases.entries) {
      test('${entry.key} -> ${entry.value.name}', () async {
        when(
          () => mockAuth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(_fbException(entry.key));

        await expectLater(
          () => repo.signUpWithEmail(email: 'a@b.com', password: 'secret1'),
          _throwsReason(entry.value),
        );
      });
    }
  });

  group('signInWithEmail — reason mapping', () {
    for (final entry in emailCases.entries) {
      test('${entry.key} -> ${entry.value.name}', () async {
        when(
          () => mockAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(_fbException(entry.key));

        await expectLater(
          () => repo.signInWithEmail(email: 'a@b.com', password: 'secret1'),
          _throwsReason(entry.value),
        );
      });
    }
  });

  group('sendPasswordReset — reason mapping', () {
    for (final entry in emailCases.entries) {
      test('${entry.key} -> ${entry.value.name}', () async {
        when(
          () => mockAuth.sendPasswordResetEmail(email: any(named: 'email')),
        ).thenThrow(_fbException(entry.key));

        await expectLater(
          () => repo.sendPasswordReset('a@b.com'),
          _throwsReason(entry.value),
        );
      });
    }
  });

  // ── phone reason mapping ───────────────────────────────────────────────────

  const phoneCases = <String, AuthErrorReason>{
    'invalid-phone-number': AuthErrorReason.invalidPhoneNumber,
    'invalid-verification-code': AuthErrorReason.invalidVerificationCode,
    'session-expired': AuthErrorReason.sessionExpired,
    'credential-already-in-use': AuthErrorReason.phoneAlreadyInUse,
    'account-exists-with-different-credential':
        AuthErrorReason.phoneAlreadyInUse,
    'requires-recent-login': AuthErrorReason.requiresRecentLogin,
    'too-many-requests': AuthErrorReason.tooManyRequests,
    'some-unmapped-code': AuthErrorReason.phoneVerificationFailed,
  };

  group('confirmPhoneCode — reason mapping', () {
    for (final entry in phoneCases.entries) {
      test('${entry.key} -> ${entry.value.name}', () async {
        when(
          () => mockAuth.signInWithCredential(any()),
        ).thenThrow(_fbException(entry.key));

        await expectLater(
          () => repo.confirmPhoneCode(verificationId: 'vid', smsCode: '123456'),
          _throwsReason(entry.value),
        );
      });
    }
  });

  group('startPhoneVerification — verificationFailed reason mapping', () {
    for (final entry in phoneCases.entries) {
      test('${entry.key} -> ${entry.value.name}', () async {
        when(
          () => mockAuth.verifyPhoneNumber(
            phoneNumber: any(named: 'phoneNumber'),
            verificationCompleted: any(named: 'verificationCompleted'),
            verificationFailed: any(named: 'verificationFailed'),
            codeSent: any(named: 'codeSent'),
            codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
          ),
        ).thenAnswer((invocation) async {
          final onFailed =
              invocation.namedArguments[#verificationFailed]
                  as PhoneVerificationFailed;
          // Deferred via scheduleMicrotask so the SUT has already returned
          // `completer.future` (and the test's matcher has attached its
          // listener) before the error is delivered — calling `onFailed`
          // synchronously here races the Completer against that listener
          // attachment and trips a spurious "unhandled error in zone".
          scheduleMicrotask(() => onFailed(_fbException(entry.key)));
        });

        await expectLater(
          () => repo.startPhoneVerification('+971500000000'),
          _throwsReason(entry.value),
        );
      });
    }

    test('codeSent completes with a PhoneVerification', () async {
      when(
        () => mockAuth.verifyPhoneNumber(
          phoneNumber: any(named: 'phoneNumber'),
          verificationCompleted: any(named: 'verificationCompleted'),
          verificationFailed: any(named: 'verificationFailed'),
          codeSent: any(named: 'codeSent'),
          codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
        ),
      ).thenAnswer((invocation) async {
        final onCodeSent =
            invocation.namedArguments[#codeSent] as PhoneCodeSent;
        onCodeSent('vid-123', 42);
      });

      final result = await repo.startPhoneVerification('+971500000000');
      expect(result.verificationId, 'vid-123');
      expect(result.resendToken, 42);
    });
  });

  group('updatePhoneNumber — reason mapping', () {
    test('throws reauthRequiredPhone when currentUser is null', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      await expectLater(
        () => repo.updatePhoneNumber(verificationId: 'vid', smsCode: '123456'),
        _throwsReason(AuthErrorReason.reauthRequiredPhone),
      );
    });

    for (final entry in phoneCases.entries) {
      test('${entry.key} -> ${entry.value.name}', () async {
        final mockUser = _MockUser();
        when(() => mockAuth.currentUser).thenReturn(mockUser);
        when(
          () => mockUser.updatePhoneNumber(any()),
        ).thenThrow(_fbException(entry.key));

        await expectLater(
          () =>
              repo.updatePhoneNumber(verificationId: 'vid', smsCode: '123456'),
          _throwsReason(entry.value),
        );
      });
    }
  });

  // ── email-update / password-update re-auth guards ──────────────────────────

  group('sendEmailUpdateVerification', () {
    test('throws reauthRequiredEmail when currentUser is null', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      await expectLater(
        () => repo.sendEmailUpdateVerification('new@example.com'),
        _throwsReason(AuthErrorReason.reauthRequiredEmail),
      );
    });

    for (final entry in emailCases.entries) {
      test('${entry.key} -> ${entry.value.name}', () async {
        final mockUser = _MockUser();
        when(() => mockAuth.currentUser).thenReturn(mockUser);
        when(
          () => mockUser.verifyBeforeUpdateEmail(any()),
        ).thenThrow(_fbException(entry.key));

        await expectLater(
          () => repo.sendEmailUpdateVerification('new@example.com'),
          _throwsReason(entry.value),
        );
      });
    }
  });

  group('updatePassword', () {
    test('throws reauthRequiredPassword when currentUser is null', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      await expectLater(
        () => repo.updatePassword('newPassword1'),
        _throwsReason(AuthErrorReason.reauthRequiredPassword),
      );
    });

    test('requires-recent-login -> reauthRequiredPassword', () async {
      final mockUser = _MockUser();
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(
        () => mockUser.updatePassword(any()),
      ).thenThrow(_fbException('requires-recent-login'));

      await expectLater(
        () => repo.updatePassword('newPassword1'),
        _throwsReason(AuthErrorReason.reauthRequiredPassword),
      );
    });

    test('weak-password -> passwordTooWeak', () async {
      final mockUser = _MockUser();
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(
        () => mockUser.updatePassword(any()),
      ).thenThrow(_fbException('weak-password'));

      await expectLater(
        () => repo.updatePassword('weak'),
        _throwsReason(AuthErrorReason.passwordTooWeak),
      );
    });

    test('any other code -> passwordUpdateFailed', () async {
      final mockUser = _MockUser();
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(
        () => mockUser.updatePassword(any()),
      ).thenThrow(_fbException('internal-error'));

      await expectLater(
        () => repo.updatePassword('newPassword1'),
        _throwsReason(AuthErrorReason.passwordUpdateFailed),
      );
    });
  });

  // ── social sign-in inline throws ────────────────────────────────────────────

  group('signInWithGoogle', () {
    test('idToken null -> googleSignInFailed', () async {
      final account = _MockGoogleSignInAccount();
      when(
        () => account.authentication,
      ).thenReturn(const GoogleSignInAuthentication(idToken: null));
      when(() => mockGoogleSignIn.authenticate()).thenAnswer((_) async {
        return account;
      });

      await expectLater(
        () => repo.signInWithGoogle(),
        _throwsReason(AuthErrorReason.googleSignInFailed),
      );
    });

    test('cancelled GoogleSignInException -> signInCancelled', () async {
      when(() => mockGoogleSignIn.authenticate()).thenThrow(
        const GoogleSignInException(code: GoogleSignInExceptionCode.canceled),
      );

      await expectLater(
        () => repo.signInWithGoogle(),
        _throwsReason(AuthErrorReason.signInCancelled),
      );
    });

    test('non-cancelled GoogleSignInException -> googleSignInFailed', () async {
      when(() => mockGoogleSignIn.authenticate()).thenThrow(
        const GoogleSignInException(
          code: GoogleSignInExceptionCode.uiUnavailable,
        ),
      );

      await expectLater(
        () => repo.signInWithGoogle(),
        _throwsReason(AuthErrorReason.googleSignInFailed),
      );
    });

    test(
      'FirebaseAuthException after successful Google auth is reason-mapped',
      () async {
        final account = _MockGoogleSignInAccount();
        when(
          () => account.authentication,
        ).thenReturn(const GoogleSignInAuthentication(idToken: 'id-token'));
        when(() => mockGoogleSignIn.authenticate()).thenAnswer((_) async {
          return account;
        });
        when(
          () => mockAuth.signInWithCredential(any()),
        ).thenThrow(_fbException('user-disabled'));

        await expectLater(
          () => repo.signInWithGoogle(),
          _throwsReason(AuthErrorReason.userDisabled),
        );
      },
    );
  });

  // NOTE(data-dev): signInWithApple() is not covered here. It calls the
  // `SignInWithApple.getAppleIDCredential(...)` *static* SDK method directly —
  // there is no injected seam to mock, so exercising its FirebaseAuthException
  // / cancel / non-cancel branches would require wrapping the static call
  // behind an injectable abstraction, which is outside this task's scope
  // (the architect-frozen contract does not add one). Flagging as a known,
  // genuinely non-mockable gap for test-reviewer.
}
