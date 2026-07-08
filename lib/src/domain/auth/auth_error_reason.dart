/// A distinct, user-facing authentication failure reason.
///
/// This is the FROZEN contract that replaces the previously-hardcoded English
/// strings thrown by `AuthException`. The data layer
/// (`firebase_auth_repository.dart`) maps Firebase codes / SDK exceptions to a
/// reason; the UI maps a reason to a localized message via `context.l10N`.
///
/// l10n mapping (ui-dev, in the AuthFailure listeners) — keys live in
/// `app_en.arb` under `@_auth_errors`:
///   invalidEmail            -> auth_error_invalid_email
///   userDisabled            -> auth_error_user_disabled
///   wrongCredentials        -> auth_error_wrong_credentials
///   emailAlreadyInUse       -> auth_error_email_already_in_use
///   weakPassword            -> auth_error_weak_password
///   operationNotAllowed     -> auth_error_operation_not_allowed
///   requiresRecentLogin     -> auth_error_requires_recent_login
///   tooManyRequests         -> auth_error_too_many_requests
///   networkRequestFailed    -> auth_error_network_request_failed
///   invalidPhoneNumber      -> auth_error_invalid_phone_number
///   invalidVerificationCode -> auth_error_invalid_verification_code
///   sessionExpired          -> auth_error_session_expired
///   phoneAlreadyInUse       -> auth_error_phone_already_in_use
///   phoneVerificationFailed -> auth_error_phone_verification_failed
///   googleSignInFailed      -> auth_error_google_sign_in_failed
///   signInCancelled         -> auth_error_sign_in_cancelled
///   appleSignInFailed       -> auth_error_apple_sign_in_failed
///   reauthRequiredEmail     -> auth_error_reauth_required_email
///   reauthRequiredPassword  -> auth_error_reauth_required_password
///   passwordTooWeak         -> auth_error_password_too_weak
///   passwordUpdateFailed    -> auth_error_password_update_failed
///   reauthRequiredPhone     -> auth_error_reauth_required_phone
///   generic                 -> auth_error_generic (reused fallback)
enum AuthErrorReason {
  // ── email / password sign-in & sign-up (Firebase code -> reason) ──────────
  /// `invalid-email`
  invalidEmail,

  /// `user-disabled`
  userDisabled,

  /// `user-not-found` | `wrong-password` | `invalid-credential`
  wrongCredentials,

  /// `email-already-in-use`
  emailAlreadyInUse,

  /// `weak-password` (sign-up path)
  weakPassword,

  /// `operation-not-allowed`
  operationNotAllowed,

  /// `requires-recent-login` (shared by email + phone mappers)
  requiresRecentLogin,

  /// `too-many-requests` (shared by email + phone mappers)
  tooManyRequests,

  /// `network-request-failed`
  networkRequestFailed,

  // ── phone verification (Firebase code -> reason) ──────────────────────────
  /// `invalid-phone-number`
  invalidPhoneNumber,

  /// `invalid-verification-code`
  invalidVerificationCode,

  /// `session-expired`
  sessionExpired,

  /// `credential-already-in-use` | `account-exists-with-different-credential`
  phoneAlreadyInUse,

  /// Default fallback for the phone code mapper.
  phoneVerificationFailed,

  // ── social sign-in (inline throws) ────────────────────────────────────────
  /// Google sign-in failed (missing idToken or non-cancel GoogleSignInException).
  googleSignInFailed,

  /// User cancelled a Google or Apple sign-in.
  signInCancelled,

  /// Apple sign-in failed (non-cancel authorization exception).
  appleSignInFailed,

  // ── account edit re-auth / password update (inline throws) ────────────────
  /// Must sign in again before changing email.
  reauthRequiredEmail,

  /// Must sign in again before changing password.
  reauthRequiredPassword,

  /// `weak-password` on the change-password path ("Please choose a stronger
  /// password.").
  passwordTooWeak,

  /// Default fallback when updating the password fails.
  passwordUpdateFailed,

  /// Must sign in again before changing phone number.
  reauthRequiredPhone,

  // ── generic ───────────────────────────────────────────────────────────────
  /// Default fallback for the email mapper / any unclassified auth error.
  generic,
}
