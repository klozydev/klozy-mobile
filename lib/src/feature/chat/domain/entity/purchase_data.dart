import 'package:equatable/equatable.dart';

/// Purchase-confirmation payload, read from a message's `metadata` map.
class PurchaseData extends Equatable {
  final String productName;
  final num amount;

  const PurchaseData({required this.productName, required this.amount});

  @override
  List<Object?> get props => <Object?>[productName, amount];
}
