import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
sealed class CheckoutEvent extends Equatable {
  const CheckoutEvent();

  @override
  List<Object?> get props => [];
}

final class CheckoutStarted extends CheckoutEvent {
  final String sellerId;

  const CheckoutStarted(this.sellerId);

  @override
  List<Object?> get props => [sellerId];
}

final class CheckoutAddressSelected extends CheckoutEvent {
  final String addressId;

  const CheckoutAddressSelected(this.addressId);

  @override
  List<Object?> get props => [addressId];
}

/// Create the order (→ a [CheckoutPaymentState] the screen presents Stripe on).
final class CheckoutPayRequested extends CheckoutEvent {
  const CheckoutPayRequested();
}

/// Dispatched by the screen after the Stripe PaymentSheet completes.
final class CheckoutPaid extends CheckoutEvent {
  const CheckoutPaid();
}

/// Dispatched by the screen if the PaymentSheet was cancelled/failed.
final class CheckoutPayCancelled extends CheckoutEvent {
  const CheckoutPayCancelled();
}
