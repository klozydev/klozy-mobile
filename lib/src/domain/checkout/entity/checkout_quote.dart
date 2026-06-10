import 'package:equatable/equatable.dart';
import 'package:klozy/src/domain/checkout/entity/order_fees.dart';

/// One selectable EMX shipping tier (price in AED).
class ShippingOption extends Equatable {
  final String shipmentType;
  final num amount;

  const ShippingOption({required this.shipmentType, required this.amount});

  @override
  List<Object?> get props => [shipmentType, amount];
}

/// Fee preview for a seller bucket at an address (`POST /v1/checkout/quote`).
/// [fees] reflect the default/cheapest tier ([shipmentType]); pick another
/// from [shippingOptions] and adjust with [feesFor]. Amounts in AED.
class CheckoutQuote extends Equatable {
  final String? addressId;
  final OrderFees fees;
  final String? shipmentType;
  final List<ShippingOption> shippingOptions;

  const CheckoutQuote({
    this.addressId,
    this.fees = const OrderFees(),
    this.shipmentType,
    this.shippingOptions = const <ShippingOption>[],
  });

  /// The breakdown with [option]'s shipping swapped in
  /// (total = total − default shipping + option price).
  OrderFees feesFor(ShippingOption option) {
    return OrderFees(
      subtotal: fees.subtotal,
      shipping: option.amount,
      protection: fees.protection,
      vat: fees.vat,
      total: fees.total - fees.shipping + option.amount,
    );
  }

  @override
  List<Object?> get props => [addressId, fees, shipmentType, shippingOptions];
}
