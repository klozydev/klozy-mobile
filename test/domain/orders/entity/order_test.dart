import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/cart/entity/cart_item.dart';
import 'package:klozy/src/domain/checkout/entity/order_fees.dart';
import 'package:klozy/src/domain/orders/entity/order.dart';
import 'package:klozy/src/domain/orders/entity/order_action.dart';
import 'package:klozy/src/domain/orders/entity/order_status.dart';
import 'package:klozy/src/domain/orders/entity/order_tracking.dart';
import 'package:klozy/src/domain/product/entity/product_detail.dart';

const ProductSeller _seller = ProductSeller(
  id: 's1',
  displayName: 'FashionHub',
);

void main() {
  group('Order', () {
    const Order order = Order(
      id: 'ord-1',
      status: OrderStatus.inDelivery,
      viewerRole: OrderRole.buyer,
      counterpart: _seller,
      availableActions: <OrderAction>{OrderAction.confirmReceipt},
      items: <CartItem>[
        CartItem(productId: 'p1', title: 'Sneakers', price: 200),
      ],
      fees: OrderFees(subtotal: 200, shipping: 10, total: 210),
      tracking: OrderTracking(carrier: 'EMX'),
      deliveryName: 'Alice',
      deliveryAddress: 'Marina Gate, Dubai',
      returnReason: null,
      createdAtLabel: '1 Jan 2024',
    );

    test('getters return constructor values', () {
      expect(order.id, 'ord-1');
      expect(order.status, OrderStatus.inDelivery);
      expect(order.viewerRole, OrderRole.buyer);
      expect(order.counterpart, _seller);
      expect(order.availableActions, contains(OrderAction.confirmReceipt));
      expect(order.items, hasLength(1));
      expect(order.fees.total, 210);
      expect(order.tracking.carrier, 'EMX');
      expect(order.deliveryName, 'Alice');
      expect(order.deliveryAddress, 'Marina Gate, Dubai');
      expect(order.returnReason, isNull);
      expect(order.createdAtLabel, '1 Jan 2024');
    });

    test('counterpartRoleLabel is Seller for buyer role', () {
      expect(order.counterpartRoleLabel, 'Seller');
    });

    test('counterpartRoleLabel is Buyer for seller role', () {
      const Order sellerOrder = Order(
        id: 'ord-2',
        status: OrderStatus.pending,
        viewerRole: OrderRole.seller,
        counterpart: _seller,
      );
      expect(sellerOrder.counterpartRoleLabel, 'Buyer');
    });

    test('defaults for optional fields', () {
      const Order minimal = Order(
        id: 'ord-min',
        status: OrderStatus.unknown,
        viewerRole: OrderRole.buyer,
        counterpart: _seller,
      );
      expect(minimal.availableActions, isEmpty);
      expect(minimal.items, isEmpty);
      expect(minimal.deliveryName, isNull);
      expect(minimal.deliveryAddress, isNull);
      expect(minimal.returnReason, isNull);
      expect(minimal.createdAtLabel, isNull);
    });

    test('two instances with same fields are equal', () {
      const Order other = Order(
        id: 'ord-1',
        status: OrderStatus.inDelivery,
        viewerRole: OrderRole.buyer,
        counterpart: _seller,
        availableActions: <OrderAction>{OrderAction.confirmReceipt},
        items: <CartItem>[
          CartItem(productId: 'p1', title: 'Sneakers', price: 200),
        ],
        fees: OrderFees(subtotal: 200, shipping: 10, total: 210),
        tracking: OrderTracking(carrier: 'EMX'),
        deliveryName: 'Alice',
        deliveryAddress: 'Marina Gate, Dubai',
        createdAtLabel: '1 Jan 2024',
      );
      expect(order, equals(other));
      expect(order.hashCode, equals(other.hashCode));
    });

    test('instances with different id are not equal', () {
      const Order other = Order(
        id: 'ord-X',
        status: OrderStatus.pending,
        viewerRole: OrderRole.buyer,
        counterpart: _seller,
      );
      expect(order, isNot(equals(other)));
    });
  });
}
