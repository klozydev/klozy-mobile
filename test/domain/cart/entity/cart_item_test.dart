import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/cart/entity/cart_item.dart';

void main() {
  group('CartItem', () {
    const CartItem item = CartItem(
      productId: 'p1',
      title: 'White Sneakers',
      brand: 'Nike',
      size: '42',
      image: 'https://example.com/shoe.jpg',
      price: 300,
      effectivePrice: 250,
      offerId: 'off-1',
      offerAmount: 250,
      offerStatus: CartOfferStatus.accepted,
      bundleId: null,
      addedAfter: false,
    );

    test('getters return constructor values', () {
      expect(item.productId, 'p1');
      expect(item.title, 'White Sneakers');
      expect(item.brand, 'Nike');
      expect(item.size, '42');
      expect(item.image, 'https://example.com/shoe.jpg');
      expect(item.price, 300);
      expect(item.effectivePrice, 250);
      expect(item.offerId, 'off-1');
      expect(item.offerAmount, 250);
      expect(item.offerStatus, CartOfferStatus.accepted);
      expect(item.bundleId, isNull);
      expect(item.addedAfter, isFalse);
    });

    test('effectivePrice defaults to price when not provided', () {
      const CartItem noEff = CartItem(
        productId: 'p2',
        title: 'Bag',
        price: 150,
      );
      expect(noEff.effectivePrice, 150);
    });

    test('inBundle is false when bundleId is null', () {
      expect(item.inBundle, isFalse);
    });

    test('inBundle is true when bundleId is set', () {
      const CartItem bundled = CartItem(
        productId: 'p3',
        title: 'Jacket',
        price: 500,
        bundleId: 'bundle-1',
      );
      expect(bundled.inBundle, isTrue);
    });

    test('hasItemOffer is true when offerId is set', () {
      expect(item.hasItemOffer, isTrue);
    });

    test('hasItemOffer is false when offerId is null', () {
      const CartItem noOffer = CartItem(
        productId: 'p4',
        title: 'Belt',
        price: 80,
      );
      expect(noOffer.hasItemOffer, isFalse);
    });

    test('offerPending is true for pending status', () {
      const CartItem pending = CartItem(
        productId: 'p5',
        title: 'Hat',
        price: 50,
        offerStatus: CartOfferStatus.pending,
      );
      expect(pending.offerPending, isTrue);
    });

    test('offerAccepted is true for accepted status', () {
      expect(item.offerAccepted, isTrue);
    });

    test('offerAccepted is false for pending status', () {
      const CartItem pending = CartItem(
        productId: 'p5',
        title: 'Hat',
        price: 50,
        offerStatus: CartOfferStatus.pending,
      );
      expect(pending.offerAccepted, isFalse);
    });

    test('meta returns brand · size when both present', () {
      expect(item.meta, 'Nike · 42');
    });

    test('meta returns only brand when size is empty', () {
      const CartItem noBrand = CartItem(
        productId: 'p6',
        title: 'Shirt',
        price: 100,
        brand: 'Zara',
        size: '',
      );
      expect(noBrand.meta, 'Zara');
    });

    test('meta is empty when brand and size are both empty', () {
      const CartItem bare = CartItem(productId: 'p7', title: 'Misc', price: 10);
      expect(bare.meta, '');
    });

    test('two instances with same fields are equal', () {
      const CartItem other = CartItem(
        productId: 'p1',
        title: 'White Sneakers',
        brand: 'Nike',
        size: '42',
        image: 'https://example.com/shoe.jpg',
        price: 300,
        effectivePrice: 250,
        offerId: 'off-1',
        offerAmount: 250,
        offerStatus: CartOfferStatus.accepted,
        addedAfter: false,
      );
      expect(item, equals(other));
      expect(item.hashCode, equals(other.hashCode));
    });

    test('instances with different productId are not equal', () {
      const CartItem other = CartItem(
        productId: 'p-X',
        title: 'White Sneakers',
        price: 300,
      );
      expect(item, isNot(equals(other)));
    });
  });

  group('CartOfferStatus', () {
    test('has all four values', () {
      expect(
        CartOfferStatus.values,
        containsAll(<CartOfferStatus>[
          CartOfferStatus.none,
          CartOfferStatus.pending,
          CartOfferStatus.accepted,
          CartOfferStatus.declined,
        ]),
      );
    });
  });
}
