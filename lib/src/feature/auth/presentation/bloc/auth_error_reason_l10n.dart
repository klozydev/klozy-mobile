import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/domain/auth/auth_error_reason.dart';

/// Localizes an [AuthErrorReason] into a user-facing message.
///
/// Shared by all `AuthFailure` listeners (phone, OTP, login pages) so the
/// mapping lives in one exhaustive place — the compiler enforces that every
/// [AuthErrorReason] case is handled.
extension AuthErrorReasonL10n on AuthErrorReason {
  String message(AppLocalizations l10n) => switch (this) {
    AuthErrorReason.invalidEmail => l10n.auth_error_invalid_email,
    AuthErrorReason.userDisabled => l10n.auth_error_user_disabled,
    AuthErrorReason.wrongCredentials => l10n.auth_error_wrong_credentials,
    AuthErrorReason.emailAlreadyInUse => l10n.auth_error_email_already_in_use,
    AuthErrorReason.weakPassword => l10n.auth_error_weak_password,
    AuthErrorReason.operationNotAllowed =>
      l10n.auth_error_operation_not_allowed,
    AuthErrorReason.requiresRecentLogin =>
      l10n.auth_error_requires_recent_login,
    AuthErrorReason.tooManyRequests => l10n.auth_error_too_many_requests,
    AuthErrorReason.networkRequestFailed =>
      l10n.auth_error_network_request_failed,
    AuthErrorReason.invalidPhoneNumber => l10n.auth_error_invalid_phone_number,
    AuthErrorReason.invalidVerificationCode =>
      l10n.auth_error_invalid_verification_code,
    AuthErrorReason.sessionExpired => l10n.auth_error_session_expired,
    AuthErrorReason.phoneAlreadyInUse => l10n.auth_error_phone_already_in_use,
    AuthErrorReason.phoneVerificationFailed =>
      l10n.auth_error_phone_verification_failed,
    AuthErrorReason.googleSignInFailed => l10n.auth_error_google_sign_in_failed,
    AuthErrorReason.signInCancelled => l10n.auth_error_sign_in_cancelled,
    AuthErrorReason.appleSignInFailed => l10n.auth_error_apple_sign_in_failed,
    AuthErrorReason.reauthRequiredEmail =>
      l10n.auth_error_reauth_required_email,
    AuthErrorReason.reauthRequiredPassword =>
      l10n.auth_error_reauth_required_password,
    AuthErrorReason.passwordTooWeak => l10n.auth_error_password_too_weak,
    AuthErrorReason.passwordUpdateFailed =>
      l10n.auth_error_password_update_failed,
    AuthErrorReason.reauthRequiredPhone =>
      l10n.auth_error_reauth_required_phone,
    AuthErrorReason.generic => l10n.auth_error_generic,
  };
}
