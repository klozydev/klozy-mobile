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

/// Quietly reloads the address book (e.g. after returning from the address
/// book screen) and re-quotes if the selection changed — without this a
/// first-time buyer who adds an address comes back to a dead "Add address"
/// card and a disabled Pay button.
final class CheckoutAddressesRefreshRequested extends CheckoutEvent {
  const CheckoutAddressesRefreshRequested();
}

final class CheckoutAddressSelected extends CheckoutEvent {
  final String addressId;

  const CheckoutAddressSelected(this.addressId);

  @override
  List<Object?> get props => [addressId];
}

final class CheckoutShipmentSelected extends CheckoutEvent {
  final String shipmentType;

  const CheckoutShipmentSelected(this.shipmentType);

  @override
  List<Object?> get props => [shipmentType];
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
