import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/offers/entity/offer.dart';

void main() {
  final DateTime ts = DateTime(2024, 5, 20);

  group('Offer', () {
    final Offer offer = Offer(
      id: 'off-1',
      amount: 350,
      status: OfferStatus.accepted,
      counterpartName: 'Bob',
      counterpartAvatar: 'https://example.com/bob.jpg',
      itemCount: 2,
      createdAt: ts,
    );

    test('getters return constructor values', () {
      expect(offer.id, 'off-1');
      expect(offer.amount, 350);
      expect(offer.status, OfferStatus.accepted);
      expect(offer.counterpartName, 'Bob');
      expect(offer.counterpartAvatar, 'https://example.com/bob.jpg');
      expect(offer.itemCount, 2);
      expect(offer.createdAt, ts);
    });

    test('optional fields default to pending / empty / zero / null', () {
      const Offer minimal = Offer(id: 'off-2', amount: 100);
      expect(minimal.status, OfferStatus.pending);
      expect(minimal.counterpartName, '');
      expect(minimal.counterpartAvatar, isNull);
      expect(minimal.itemCount, 0);
      expect(minimal.createdAt, isNull);
    });

    test('two instances with same fields are equal', () {
      final Offer other = Offer(
        id: 'off-1',
        amount: 350,
        status: OfferStatus.accepted,
        counterpartName: 'Bob',
        counterpartAvatar: 'https://example.com/bob.jpg',
        itemCount: 2,
        createdAt: ts,
      );
      expect(offer, equals(other));
      expect(offer.hashCode, equals(other.hashCode));
    });

    test('instances with different id are not equal', () {
      const Offer other = Offer(id: 'off-X', amount: 100);
      expect(offer, isNot(equals(other)));
    });
  });

  group('OfferStatus', () {
    test('has all five values', () {
      expect(
        OfferStatus.values,
        containsAll(<OfferStatus>[
          OfferStatus.pending,
          OfferStatus.accepted,
          OfferStatus.declined,
          OfferStatus.cancelled,
          OfferStatus.unknown,
        ]),
      );
    });
  });
}
