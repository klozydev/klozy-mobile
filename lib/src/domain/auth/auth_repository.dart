import 'package:klozy/src/domain/auth/entity/auth_user.dart';

/// Result of starting phone verification — carries the Firebase `verificationId`
/// needed to confirm the SMS code, and whether the platform auto-resolved it.
class PhoneVerification {
  final String verificationId;
  final int? resendToken;

  const PhoneVerification({required this.verificationId, this.resendToken});
}

/// Firebase-backed authentication. Implementations live in the data layer.
abstract class AuthRepository {
  /// Emits the current [AuthUser] on sign-in/out (null when signed out).
  Stream<AuthUser?> authStateChanges();

  AuthUser? get currentUser;

  /// The current Firebase user id, or null when signed out. Exposed so the
  /// domain (e.g. `GetAccountStatusUseCase`) can detect the guest state without
  /// depending on FirebaseAuth.
  String? get currentUserId;

  /// Whether the current Firebase user is anonymous. Used to classify legacy
  /// anonymous sessions as [AccountStatus.legacy] without leaking FirebaseAuth.
  bool get isAnonymous;

  Future<AuthUser> signUpWithEmail({
    required String email,
    required String password,
  });

  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  });

  Future<void> sendPasswordReset(String email);

  /// Sets a new password for the signed-in user (Firebase `updatePassword`).
  /// May throw [AuthException] with a "sign in again" message when the session
  /// is stale (`requires-recent-login`).
  Future<void> updatePassword(String newPassword);

  Future<AuthUser> signInWithGoogle();

  Future<AuthUser> signInWithApple();

  /// Starts phone verification; the SMS code is then confirmed via
  /// [confirmPhoneCode]. On Android the code may auto-resolve.
  Future<PhoneVerification> startPhoneVerification(String phoneNumber);

  Future<AuthUser> confirmPhoneCode({
    required String verificationId,
    required String smsCode,
  });

  /// Sends a confirmation link to [newEmail]; the address change applies only
  /// once the user clicks it (Firebase `verifyBeforeUpdateEmail`). May throw
  /// [AuthException] with a "sign in again" message when the session is stale
  /// (`requires-recent-login`).
  Future<void> sendEmailUpdateVerification(String newEmail);

  /// Re-verifies and attaches a new phone number to the current account
  /// (Firebase `updatePhoneNumber`). Use [startPhoneVerification] to obtain the
  /// [verificationId] and the SMS [smsCode] entered by the user.
  Future<void> updatePhoneNumber({
    required String verificationId,
    required String smsCode,
  });

  Future<void> signOut();
}
