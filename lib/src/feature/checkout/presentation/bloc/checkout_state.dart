import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/domain/checkout/entity/checkout_quote.dart';
import 'package:klozy/src/domain/checkout/entity/checkout_result.dart';
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

  const CheckoutErrorState({required this.type});

  @override
  List<Object?> get props => [type];
}

final class CheckoutReadyState extends CheckoutState {
  final List<Address> addresses;
  final String? selectedAddressId;
  final CheckoutQuote quote;
  final bool isQuoting;
  final bool isCreating;

  const CheckoutReadyState({
    required this.addresses,
    required this.quote,
    this.selectedAddressId,
    this.isQuoting = false,
    this.isCreating = false,
  });

  CheckoutReadyState copyWith({
    CheckoutQuote? quote,
    String? selectedAddressId,
    bool? isQuoting,
    bool? isCreating,
  }) {
    return CheckoutReadyState(
      addresses: addresses,
      quote: quote ?? this.quote,
      selectedAddressId: selectedAddressId ?? this.selectedAddressId,
      isQuoting: isQuoting ?? this.isQuoting,
      isCreating: isCreating ?? this.isCreating,
    );
  }

  @override
  List<Object?> get props => [
    addresses,
    selectedAddressId,
    quote,
    isQuoting,
    isCreating,
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
