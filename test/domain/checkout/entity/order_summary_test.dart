import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/cart/entity/cart_item.dart';
import 'package:klozy/src/domain/checkout/entity/order_fees.dart';
import 'package:klozy/src/domain/checkout/entity/order_summary.dart';

void main() {
  group('OrderSummary', () {
    const CartItem item = CartItem(
      productId: 'p1',
      title: 'Sneakers',
      price: 200,
    );
    const OrderFees fees = OrderFees(subtotal: 200, shipping: 15, total: 215);

    const OrderSummary summary = OrderSummary(
      orderId: 'ord-1',
      items: <CartItem>[item],
      fees: fees,
      sellerName: 'StyleHub',
      sellerAvatar: 'https://example.com/s.jpg',
      deliveryName: 'Alice',
      deliveryAddress: 'Marina Gate, Dubai',
    );

    test('getters return constructor values', () {
      expect(summary.orderId, 'ord-1');
      expect(summary.items, <CartItem>[item]);
      expect(summary.fees, fees);
      expect(summary.sellerName, 'StyleHub');
      expect(summary.sellerAvatar, 'https://example.com/s.jpg');
      expect(summary.deliveryName, 'Alice');
      expect(summary.deliveryAddress, 'Marina Gate, Dubai');
    });

    test('optional fields default to empty / null', () {
      const OrderSummary minimal = OrderSummary(
        orderId: 'ord-2',
        items: <CartItem>[],
        fees: OrderFees(),
      );
      expect(minimal.sellerName, '');
      expect(minimal.sellerAvatar, isNull);
      expect(minimal.deliveryName, isNull);
      expect(minimal.deliveryAddress, isNull);
    });

    test('two instances with same fields are equal', () {
      const OrderSummary other = OrderSummary(
        orderId: 'ord-1',
        items: <CartItem>[item],
        fees: fees,
        sellerName: 'StyleHub',
        sellerAvatar: 'https://example.com/s.jpg',
        deliveryName: 'Alice',
        deliveryAddress: 'Marina Gate, Dubai',
      );
      expect(summary, equals(other));
      expect(summary.hashCode, equals(other.hashCode));
    });

    test('instances with different orderId are not equal', () {
      const OrderSummary other = OrderSummary(
        orderId: 'ord-X',
        items: <CartItem>[],
        fees: OrderFees(),
      );
      expect(summary, isNot(equals(other)));
    });
  });
}
