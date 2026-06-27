import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/cart/entity/cart_bucket.dart';
import 'package:klozy/src/domain/cart/entity/cart_bundle.dart';
import 'package:klozy/src/domain/cart/entity/cart_item.dart';

void main() {
  const CartItem standalone = CartItem(
    productId: 'p1',
    title: 'Sneakers',
    price: 200,
  );
  const CartItem bundledItem = CartItem(
    productId: 'p2',
    title: 'Shirt',
    price: 100,
    bundleId: 'bundle-1',
  );
  const CartItem withOffer = CartItem(
    productId: 'p3',
    title: 'Bag',
    price: 150,
    offerId: 'off-1',
  );

  group('CartBucket', () {
    const CartBucket bucket = CartBucket(
      sellerId: 's1',
      sellerName: 'FashionHub',
      sellerAvatar: 'https://example.com/hub.jpg',
      isPro: true,
      items: <CartItem>[standalone, bundledItem, withOffer],
      subtotal: 450,
      bundles: <CartBundle>[],
      canBundle: true,
    );

    test('getters return constructor values', () {
      expect(bucket.sellerId, 's1');
      expect(bucket.sellerName, 'FashionHub');
      expect(bucket.sellerAvatar, 'https://example.com/hub.jpg');
      expect(bucket.isPro, isTrue);
      expect(bucket.items, hasLength(3));
      expect(bucket.subtotal, 450);
      expect(bucket.bundles, isEmpty);
      expect(bucket.canBundle, isTrue);
    });

    test(
      'standaloneProductIds returns only items without bundle and without offer',
      () {
        final List<String> ids = bucket.standaloneProductIds;
        expect(ids, <String>['p1']);
        expect(ids, isNot(contains('p2')));
        expect(ids, isNot(contains('p3')));
      },
    );

    test(
      'standaloneProductIds is empty when all items are bundled or have offers',
      () {
        const CartBucket noneStandalone = CartBucket(
          sellerId: 's2',
          items: <CartItem>[bundledItem, withOffer],
          subtotal: 250,
        );
        expect(noneStandalone.standaloneProductIds, isEmpty);
      },
    );

    test('optional fields default to empty / false / null', () {
      const CartBucket minimal = CartBucket(
        sellerId: 's3',
        items: <CartItem>[],
        subtotal: 0,
      );
      expect(minimal.sellerName, '');
      expect(minimal.sellerAvatar, isNull);
      expect(minimal.isPro, isFalse);
      expect(minimal.bundles, isEmpty);
      expect(minimal.canBundle, isFalse);
    });

    test('two instances with same fields are equal', () {
      const CartBucket other = CartBucket(
        sellerId: 's1',
        sellerName: 'FashionHub',
        sellerAvatar: 'https://example.com/hub.jpg',
        isPro: true,
        items: <CartItem>[standalone, bundledItem, withOffer],
        subtotal: 450,
        bundles: <CartBundle>[],
        canBundle: true,
      );
      expect(bucket, equals(other));
      expect(bucket.hashCode, equals(other.hashCode));
    });

    test('instances with different sellerId are not equal', () {
      const CartBucket other = CartBucket(
        sellerId: 's-X',
        items: <CartItem>[],
        subtotal: 0,
      );
      expect(bucket, isNot(equals(other)));
    });
  });
}
