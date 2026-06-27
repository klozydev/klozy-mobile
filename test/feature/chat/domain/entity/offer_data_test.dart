import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/chat/domain/entity/offer_data.dart';

void main() {
  group('OfferData', () {
    const OfferData pending = OfferData(
      offerId: 'off-1',
      productName: 'Blue Jacket',
      listedPrice: 500,
      offerPrice: 400,
    );

    const OfferData accepted = OfferData(
      offerId: 'off-2',
      productName: 'Sneakers',
      listedPrice: 300,
      offerPrice: 250,
      accepted: true,
    );

    const OfferData refused = OfferData(
      offerId: 'off-3',
      productName: 'Belt',
      listedPrice: 100,
      offerPrice: 80,
      accepted: false,
    );

    const OfferData cancelled = OfferData(
      offerId: 'off-4',
      productName: 'Hat',
      listedPrice: 60,
      offerPrice: 50,
      cancelled: true,
    );

    test('getters return constructor values for pending', () {
      expect(pending.offerId, 'off-1');
      expect(pending.productName, 'Blue Jacket');
      expect(pending.listedPrice, 500);
      expect(pending.offerPrice, 400);
      expect(pending.accepted, isNull);
      expect(pending.cancelled, isFalse);
    });

    test('isPending is true when accepted is null and not cancelled', () {
      expect(pending.isPending, isTrue);
    });

    test('isPending is false when accepted', () {
      expect(accepted.isPending, isFalse);
    });

    test('isPending is false when cancelled', () {
      expect(cancelled.isPending, isFalse);
    });

    test('isAccepted is true only when accepted == true', () {
      expect(accepted.isAccepted, isTrue);
      expect(pending.isAccepted, isFalse);
      expect(refused.isAccepted, isFalse);
    });

    test('isRefused is true when accepted == false', () {
      expect(refused.isRefused, isTrue);
    });

    test('isRefused is true when cancelled', () {
      expect(cancelled.isRefused, isTrue);
    });

    test('isRefused is false when pending', () {
      expect(pending.isRefused, isFalse);
    });

    test('two instances with same fields are equal', () {
      const OfferData other = OfferData(
        offerId: 'off-1',
        productName: 'Blue Jacket',
        listedPrice: 500,
        offerPrice: 400,
      );
      expect(pending, equals(other));
      expect(pending.hashCode, equals(other.hashCode));
    });

    test('instances with different offerId are not equal', () {
      const OfferData other = OfferData(
        offerId: 'off-X',
        productName: 'Blue Jacket',
        listedPrice: 500,
        offerPrice: 400,
      );
      expect(pending, isNot(equals(other)));
    });
  });
}
