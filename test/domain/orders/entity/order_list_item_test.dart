import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/orders/entity/order_list_item.dart';
import 'package:klozy/src/domain/orders/entity/order_status.dart';

void main() {
  group('OrderListItem', () {
    const OrderListItem item = OrderListItem(
      id: 'ord-1',
      title: 'White Sneakers',
      coverImage: 'https://example.com/img.jpg',
      price: 250,
      status: OrderStatus.inDelivery,
      counterpartName: 'Eve',
      createdAtLabel: '2 Jan 2024',
    );

    test('getters return constructor values', () {
      expect(item.id, 'ord-1');
      expect(item.title, 'White Sneakers');
      expect(item.coverImage, 'https://example.com/img.jpg');
      expect(item.price, 250);
      expect(item.status, OrderStatus.inDelivery);
      expect(item.counterpartName, 'Eve');
      expect(item.createdAtLabel, '2 Jan 2024');
    });

    test('optional fields default to null / empty', () {
      const OrderListItem minimal = OrderListItem(
        id: 'ord-2',
        title: 'Bag',
        price: 50,
        status: OrderStatus.pending,
      );
      expect(minimal.coverImage, isNull);
      expect(minimal.counterpartName, '');
      expect(minimal.createdAtLabel, isNull);
    });

    test('two instances with same fields are equal', () {
      const OrderListItem other = OrderListItem(
        id: 'ord-1',
        title: 'White Sneakers',
        coverImage: 'https://example.com/img.jpg',
        price: 250,
        status: OrderStatus.inDelivery,
        counterpartName: 'Eve',
        createdAtLabel: '2 Jan 2024',
      );
      expect(item, equals(other));
      expect(item.hashCode, equals(other.hashCode));
    });

    test('instances with different id are not equal', () {
      const OrderListItem other = OrderListItem(
        id: 'ord-99',
        title: 'Bag',
        price: 10,
        status: OrderStatus.pending,
      );
      expect(item, isNot(equals(other)));
    });
  });
}
