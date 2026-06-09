import 'package:equatable/equatable.dart';

class OrderFees extends Equatable {
  final num subtotal;
  final num shipping;
  final num protection;
  final num vat;
  final num total;

  const OrderFees({
    this.subtotal = 0,
    this.shipping = 0,
    this.protection = 0,
    this.vat = 0,
    this.total = 0,
  });

  @override
  List<Object?> get props => [subtotal, shipping, protection, vat, total];
}
