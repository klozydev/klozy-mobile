import 'package:klozy/src/domain/checkout/entity/checkout_quote.dart';
import 'package:klozy/src/domain/checkout/entity/checkout_result.dart';

/// Checkout (`/v1/checkout`).
abstract class CheckoutRepository {
  /// `POST /v1/checkout/quote` — preview fees for [sellerId] at an address
  /// (no order created).
  Future<CheckoutQuote> quote(String sellerId, {String? addressId});

  /// `POST /v1/checkout` — creates the order for [sellerId] (optionally at
  /// [addressId], with the chosen [shipmentType] tier) and returns the order
  /// summary + Stripe PaymentSheet data.
  Future<CheckoutResult> checkout(
    String sellerId, {
    String? addressId,
    String? shipmentType,
  });
}
