import 'package:equatable/equatable.dart';

enum PayoutStatus { pending, completed, reversal }

enum PayoutMethod { stripeConnect, iban, unknown }

/// A single payout line (`GET /v1/me/payouts`). Amounts are in **fils**.
class PayoutItem extends Equatable {
  final String orderId;
  final int grossFils;
  final int commissionFils;
  final int netFils;
  final PayoutStatus status;
  final PayoutMethod method;
  final DateTime? createdAt;

  const PayoutItem({
    required this.orderId,
    this.grossFils = 0,
    this.commissionFils = 0,
    this.netFils = 0,
    this.status = PayoutStatus.pending,
    this.method = PayoutMethod.unknown,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    orderId,
    grossFils,
    commissionFils,
    netFils,
    status,
    method,
    createdAt,
  ];
}

class PayoutSummary extends Equatable {
  final int pendingFils;
  final int lifetimePaidFils;
  final List<PayoutItem> items;

  const PayoutSummary({
    this.pendingFils = 0,
    this.lifetimePaidFils = 0,
    this.items = const <PayoutItem>[],
  });

  @override
  List<Object?> get props => [pendingFils, lifetimePaidFils, items];
}
