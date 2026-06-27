import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
sealed class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Fired at app start (and after sign-out) to resolve the session integrity
/// into an [AccountStatus].
@immutable
final class AccountBootstrapRequested extends AccountEvent {
  const AccountBootstrapRequested();
}

/// Fired right after a successful interactive sign-in/sign-up. The auth flow
/// already learned whether the profile is complete (via `GET /v1/me`, which
/// also provisions a brand-new user), so we resolve the session directly from
/// that instead of re-running [GetAccountStatusUseCase]. Re-resolving here is
/// unsafe immediately post-signup: the backend profile may not be readable yet
/// (a transient 404), which the usecase maps to `legacy` → silent sign-out →
/// the Chat/Profile tabs flash the guest "login / sign up" placeholder for a
/// user who is, in fact, signed in.
@immutable
final class AccountAuthenticated extends AccountEvent {
  /// Whether the Klozy profile is complete (name + address). Drives the
  /// resolved status: true → [AccountStatus.valid], false →
  /// [AccountStatus.incompleteOnboarding].
  final bool onboardingComplete;

  const AccountAuthenticated({required this.onboardingComplete});

  @override
  List<Object?> get props => <Object?>[onboardingComplete];
}
