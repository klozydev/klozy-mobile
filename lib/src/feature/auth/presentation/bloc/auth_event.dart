import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class AuthEmailSubmitted extends AuthEvent {
  final String email;
  final String password;
  final bool isSignUp;

  const AuthEmailSubmitted({
    required this.email,
    required this.password,
    required this.isSignUp,
  });

  @override
  List<Object?> get props => [email, password, isSignUp];
}

final class AuthGooglePressed extends AuthEvent {
  const AuthGooglePressed();
}

final class AuthApplePressed extends AuthEvent {
  const AuthApplePressed();
}

final class AuthPasswordResetRequested extends AuthEvent {
  final String email;

  const AuthPasswordResetRequested(this.email);

  @override
  List<Object?> get props => [email];
}

final class AuthPhoneStarted extends AuthEvent {
  final String phoneNumber;

  const AuthPhoneStarted(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

final class AuthPhoneCodeSubmitted extends AuthEvent {
  final String verificationId;
  final String smsCode;

  const AuthPhoneCodeSubmitted({
    required this.verificationId,
    required this.smsCode,
  });

  @override
  List<Object?> get props => [verificationId, smsCode];
}
