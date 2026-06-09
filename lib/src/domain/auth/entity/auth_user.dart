import 'package:equatable/equatable.dart';

/// The authenticated Firebase identity (not the Klozy profile — that comes from
/// `GET /v1/me`). Used by the app shell to decide signed-in vs signed-out.
class AuthUser extends Equatable {
  final String uid;
  final String? email;
  final String? phoneNumber;
  final String? displayName;
  final String? photoUrl;
  final bool emailVerified;

  const AuthUser({
    required this.uid,
    this.email,
    this.phoneNumber,
    this.displayName,
    this.photoUrl,
    this.emailVerified = false,
  });

  @override
  List<Object?> get props => [
    uid,
    email,
    phoneNumber,
    displayName,
    photoUrl,
    emailVerified,
  ];
}
