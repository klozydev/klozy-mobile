import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/domain/checkout/entity/checkout_quote.dart';
import 'package:klozy/src/domain/checkout/entity/checkout_result.dart';
import 'package:klozy/src/domain/checkout/entity/order_fees.dart';
import 'package:klozy/src/domain/me/entity/address.dart';

@immutable
sealed class CheckoutState extends Equatable {
  const CheckoutState();

  @override
  List<Object?> get props => [];
}

final class CheckoutLoadingState extends CheckoutState {
  const CheckoutLoadingState();
}

final class CheckoutErrorState extends CheckoutState {
  final AppErrorType type;

  /// Server-provided message (e.g. a 409 "items no longer available").
  final String? message;

  const CheckoutErrorState({required this.type, this.message});

  @override
  List<Object?> get props => [type, message];
}

final class CheckoutReadyState extends CheckoutState {
  final List<Address> addresses;
  final String? selectedAddressId;
  final CheckoutQuote quote;
  final String? selectedShipmentType;
  final bool isQuoting;
  final bool isCreating;

  /// Transient one-shot error surfaced as a snackbar (e.g. a failed Pay
  /// attempt) while keeping the review screen visible. Null on every normal
  /// emit; set only after a checkout failure.
  final String? payError;

  const CheckoutReadyState({
    required this.addresses,
    required this.quote,
    this.selectedAddressId,
    this.selectedShipmentType,
    this.isQuoting = false,
    this.isCreating = false,
    this.payError,
  });

  /// Fees for the selected shipping tier (the quote's default otherwise).
  OrderFees get effectiveFees {
    final type = selectedShipmentType;
    if (type == null || type == quote.shipmentType) return quote.fees;
    for (final ShippingOption option in quote.shippingOptions) {
      if (option.shipmentType == type) return quote.feesFor(option);
    }
    return quote.fees;
  }

  CheckoutReadyState copyWith({
    CheckoutQuote? quote,
    String? selectedAddressId,
    String? selectedShipmentType,
    bool? isQuoting,
    bool? isCreating,
    String? payError,
  }) {
    return CheckoutReadyState(
      addresses: addresses,
      quote: quote ?? this.quote,
      selectedAddressId: selectedAddressId ?? this.selectedAddressId,
      selectedShipmentType: selectedShipmentType ?? this.selectedShipmentType,
      isQuoting: isQuoting ?? this.isQuoting,
      isCreating: isCreating ?? this.isCreating,
      payError: payError,
    );
  }

  @override
  List<Object?> get props => [
    addresses,
    selectedAddressId,
    quote,
    selectedShipmentType,
    isQuoting,
    isCreating,
    payError,
  ];
}

/// Order created — the screen presents the Stripe PaymentSheet from [result].
final class CheckoutPaymentState extends CheckoutState {
  final CheckoutResult result;

  const CheckoutPaymentState(this.result);

  @override
  List<Object?> get props => [result];
}

final class CheckoutDoneState extends CheckoutState {
  final String orderId;

  const CheckoutDoneState(this.orderId);

  @override
  List<Object?> get props => [orderId];
}
