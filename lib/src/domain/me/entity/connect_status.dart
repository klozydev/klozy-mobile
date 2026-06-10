import 'package:equatable/equatable.dart';

enum ConnectOnboarding { notStarted, pending, complete }

/// Stripe Connect (vendor KYB) status (`GET /v1/me/seller-connect`).
class ConnectStatus extends Equatable {
  final String? accountId;
  final ConnectOnboarding onboarding;
  final bool detailsSubmitted;
  final bool chargesEnabled;
  final bool payoutsEnabled;

  const ConnectStatus({
    this.accountId,
    this.onboarding = ConnectOnboarding.notStarted,
    this.detailsSubmitted = false,
    this.chargesEnabled = false,
    this.payoutsEnabled = false,
  });

  @override
  List<Object?> get props => [
    accountId,
    onboarding,
    detailsSubmitted,
    chargesEnabled,
    payoutsEnabled,
  ];
}
