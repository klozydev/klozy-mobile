import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/cart/entity/cart_item.dart';
import 'package:klozy/src/domain/checkout/entity/checkout_result.dart';
import 'package:klozy/src/domain/checkout/entity/order_fees.dart';
import 'package:klozy/src/domain/checkout/entity/order_summary.dart';
import 'package:klozy/src/domain/checkout/entity/payment_sheet_data.dart';

void main() {
  const OrderSummary order = OrderSummary(
    orderId: 'ord-1',
    items: <CartItem>[],
    fees: OrderFees(),
  );
  const PaymentSheetData payment = PaymentSheetData(
    clientSecret: 'cs_test',
    ephemeralKey: 'ek_test',
    customerId: 'cus_1',
    publishableKey: 'pk_test',
  );

  group('CheckoutResult', () {
    const CheckoutResult result = CheckoutResult(
      order: order,
      payment: payment,
    );

    test('getters return constructor values', () {
      expect(result.order, order);
      expect(result.payment, payment);
    });

    test('two instances with same fields are equal', () {
      const CheckoutResult other = CheckoutResult(
        order: order,
        payment: payment,
      );
      expect(result, equals(other));
      expect(result.hashCode, equals(other.hashCode));
    });

    test('instances with different order are not equal', () {
      const OrderSummary otherOrder = OrderSummary(
        orderId: 'ord-X',
        items: <CartItem>[],
        fees: OrderFees(),
      );
      const CheckoutResult other = CheckoutResult(
        order: otherOrder,
        payment: payment,
      );
      expect(result, isNot(equals(other)));
    });
  });
}
