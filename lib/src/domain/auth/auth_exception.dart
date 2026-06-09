/// A user-facing authentication failure (wrong password, email in use, cancelled
/// social sign-in, …). Carries a message safe to show in the UI.
class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
