import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:klozy/src/domain/auth/auth_error_reason.dart';
import 'package:klozy/src/domain/auth/auth_repository.dart';
import 'package:klozy/src/domain/auth/entity/auth_user.dart';

@immutable
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthIdle extends AuthState {
  const AuthIdle();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Phone verification SMS sent — the OTP screen confirms the code.
final class AuthCodeSent extends AuthState {
  final PhoneVerification verification;
  final String destination;

  const AuthCodeSent({required this.verification, required this.destination});

  @override
  List<Object?> get props => [verification.verificationId, destination];
}

final class AuthPasswordResetSent extends AuthState {
  const AuthPasswordResetSent();
}

final class AuthSuccess extends AuthState {
  final AuthUser user;

  /// Whether the Klozy profile is complete (name + address) — drives the
  /// post-auth route: true → shell, false → onboarding.
  final bool onboardingComplete;

  const AuthSuccess(this.user, {required this.onboardingComplete});

  @override
  List<Object?> get props => [user, onboardingComplete];
}

final class AuthFailure extends AuthState {
  final AuthErrorReason reason;

  const AuthFailure(this.reason);

  @override
  List<Object?> get props => [reason];
}
