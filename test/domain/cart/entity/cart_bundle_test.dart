import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/cart/entity/cart_bundle.dart';
import 'package:klozy/src/domain/cart/entity/cart_item.dart';

void main() {
  group('CartBundle', () {
    const CartBundle bundle = CartBundle(
      id: 'bundle-1',
      amount: 400,
      status: CartOfferStatus.accepted,
      productIds: <String>['p1', 'p2', 'p3'],
      listSum: 600,
    );

    test('getters return constructor values', () {
      expect(bundle.id, 'bundle-1');
      expect(bundle.amount, 400);
      expect(bundle.status, CartOfferStatus.accepted);
      expect(bundle.productIds, <String>['p1', 'p2', 'p3']);
      expect(bundle.listSum, 600);
    });

    test('itemCount returns productIds.length', () {
      expect(bundle.itemCount, 3);
    });

    test('accepted is true when status is accepted', () {
      expect(bundle.accepted, isTrue);
    });

    test('accepted is false when status is pending', () {
      const CartBundle pending = CartBundle(
        id: 'bundle-2',
        amount: 300,
        status: CartOfferStatus.pending,
        productIds: <String>['p4'],
        listSum: 400,
      );
      expect(pending.accepted, isFalse);
    });

    test('two instances with same fields are equal', () {
      const CartBundle other = CartBundle(
        id: 'bundle-1',
        amount: 400,
        status: CartOfferStatus.accepted,
        productIds: <String>['p1', 'p2', 'p3'],
        listSum: 600,
      );
      expect(bundle, equals(other));
      expect(bundle.hashCode, equals(other.hashCode));
    });

    test('instances with different id are not equal', () {
      const CartBundle other = CartBundle(
        id: 'bundle-X',
        amount: 400,
        status: CartOfferStatus.pending,
        productIds: <String>['p1'],
        listSum: 500,
      );
      expect(bundle, isNot(equals(other)));
    });
  });
}
