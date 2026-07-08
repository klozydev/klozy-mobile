import 'package:klozy/src/domain/auth/auth_error_reason.dart';

/// A user-facing authentication failure (wrong password, email in use, cancelled
/// social sign-in, …).
///
/// Carries a structured [reason] — never a pre-formatted English string. The UI
/// localizes [reason] via `context.l10N`. [debugDetail] is an optional,
/// non-displayed diagnostic string (e.g. the raw Firebase message) kept only for
/// logging.
class AuthException implements Exception {
  final AuthErrorReason reason;
  final String? debugDetail;

  const AuthException(this.reason, {this.debugDetail});

  @override
  String toString() =>
      'AuthException(${reason.name})'
      '${debugDetail != null ? ': $debugDetail' : ''}';
}
