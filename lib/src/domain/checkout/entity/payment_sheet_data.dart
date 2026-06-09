import 'package:equatable/equatable.dart';

/// Stripe PaymentSheet contract returned by `POST /v1/checkout`.
class PaymentSheetData extends Equatable {
  final String clientSecret;
  final String ephemeralKey;
  final String customerId;
  final String publishableKey;
  final num amountFils;

  const PaymentSheetData({
    required this.clientSecret,
    required this.ephemeralKey,
    required this.customerId,
    required this.publishableKey,
    this.amountFils = 0,
  });

  bool get isValid =>
      clientSecret.isNotEmpty &&
      ephemeralKey.isNotEmpty &&
      customerId.isNotEmpty &&
      publishableKey.isNotEmpty;

  @override
  List<Object?> get props => [
    clientSecret,
    ephemeralKey,
    customerId,
    publishableKey,
    amountFils,
  ];
}
