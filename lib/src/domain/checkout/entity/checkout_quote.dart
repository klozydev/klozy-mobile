import 'package:equatable/equatable.dart';
import 'package:klozy/src/domain/checkout/entity/order_fees.dart';

/// Fee preview for a seller bucket at an address (`POST /v1/checkout/quote`).
/// [fees] are converted to AED; no order is created.
class CheckoutQuote extends Equatable {
  final String? addressId;
  final OrderFees fees;

  const CheckoutQuote({this.addressId, this.fees = const OrderFees()});

  @override
  List<Object?> get props => [addressId, fees];
}
