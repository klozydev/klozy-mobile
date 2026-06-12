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

  /// Previous attempt's Firebase resend token — set when resending so the
  /// resend fast-path is used instead of a brand-new verification.
  final int? resendToken;

  const AuthPhoneStarted(this.phoneNumber, {this.resendToken});

  @override
  List<Object?> get props => [phoneNumber, resendToken];
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
