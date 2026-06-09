import 'package:equatable/equatable.dart';
import 'package:klozy/src/domain/checkout/entity/order_summary.dart';
import 'package:klozy/src/domain/checkout/entity/payment_sheet_data.dart';

class CheckoutResult extends Equatable {
  final OrderSummary order;
  final PaymentSheetData payment;

  const CheckoutResult({required this.order, required this.payment});

  @override
  List<Object?> get props => [order, payment];
}
