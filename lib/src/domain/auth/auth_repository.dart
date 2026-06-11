import 'package:klozy/src/domain/auth/entity/auth_user.dart';

/// Result of starting phone verification — carries the Firebase `verificationId`
/// needed to confirm the SMS code, and whether the platform auto-resolved it.
class PhoneVerification {
  final String verificationId;
  final int? resendToken;

  /// Set when the platform auto-verified the number (Android instant
  /// verification / SMS auto-retrieval): the user is already signed in and no
  /// OTP entry is needed. [verificationId] is empty in that case.
  final AuthUser? autoSignedInUser;

  const PhoneVerification({
    required this.verificationId,
    this.resendToken,
    this.autoSignedInUser,
  });
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

  Future<AuthUser> signInWithGoogle();

  Future<AuthUser> signInWithApple();

  /// Starts phone verification; the SMS code is then confirmed via
  /// [confirmPhoneCode]. On Android the code may auto-resolve (see
  /// [PhoneVerification.autoSignedInUser]). Pass the previous attempt's
  /// [resendToken] when resending so Firebase uses the resend fast-path
  /// instead of starting a brand-new verification.
  Future<PhoneVerification> startPhoneVerification(
    String phoneNumber, {
    int? resendToken,
  });

  Future<AuthUser> confirmPhoneCode({
    required String verificationId,
    required String smsCode,
  });

  Future<void> signOut();
}
