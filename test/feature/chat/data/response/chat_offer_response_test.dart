import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/chat/data/response/chat_offer_response.dart';

void main() {
  // ── fromJson ────────────────────────────────────────────────────────────────

  group('ChatOfferResponse.fromJson', () {
    test('parses all fields', () {
      final ChatOfferResponse r = ChatOfferResponse.fromJson(<String, dynamic>{
        'offerId': 'off-1',
        'productName': 'Nike Shoes',
        'listedPrice': 100,
        'offerPrice': 80,
        'accepted': true,
        'cancelled': false,
      });

      expect(r.offerId, 'off-1');
      expect(r.productName, 'Nike Shoes');
      expect(r.listedPrice, 100);
      expect(r.offerPrice, 80);
      expect(r.accepted, isTrue);
      expect(r.cancelled, isFalse);
    });

    test('parses all fields as null when absent', () {
      final ChatOfferResponse r = ChatOfferResponse.fromJson(
        <String, dynamic>{},
      );

      expect(r.offerId, isNull);
      expect(r.productName, isNull);
      expect(r.listedPrice, isNull);
      expect(r.offerPrice, isNull);
      expect(r.accepted, isNull);
      expect(r.cancelled, isNull);
    });

    test('parses accepted false and cancelled true', () {
      final ChatOfferResponse r = ChatOfferResponse.fromJson(<String, dynamic>{
        'offerId': 'off-2',
        'accepted': false,
        'cancelled': true,
      });

      expect(r.accepted, isFalse);
      expect(r.cancelled, isTrue);
    });

    test('parses decimal prices', () {
      final ChatOfferResponse r = ChatOfferResponse.fromJson(<String, dynamic>{
        'listedPrice': 99.99,
        'offerPrice': 79.50,
      });

      expect(r.listedPrice, 99.99);
      expect(r.offerPrice, 79.50);
    });
  });

  // ── toJson ──────────────────────────────────────────────────────────────────

  group('ChatOfferResponse.toJson', () {
    test('serialises all fields', () {
      const ChatOfferResponse r = ChatOfferResponse(
        offerId: 'off-3',
        productName: 'Jacket',
        listedPrice: 200,
        offerPrice: 150,
        accepted: false,
        cancelled: false,
      );

      final Map<String, dynamic> json = r.toJson();

      expect(json['offerId'], 'off-3');
      expect(json['productName'], 'Jacket');
      expect(json['listedPrice'], 200);
      expect(json['offerPrice'], 150);
      expect(json['accepted'], isFalse);
      expect(json['cancelled'], isFalse);
    });

    test('serialises null fields as null', () {
      const ChatOfferResponse r = ChatOfferResponse();

      final Map<String, dynamic> json = r.toJson();

      expect(json['offerId'], isNull);
      expect(json['productName'], isNull);
      expect(json['listedPrice'], isNull);
      expect(json['offerPrice'], isNull);
      expect(json['accepted'], isNull);
      expect(json['cancelled'], isNull);
    });
  });

  // ── round-trip ──────────────────────────────────────────────────────────────

  group('ChatOfferResponse round-trip', () {
    test('fromJson → toJson is identity for all fields', () {
      final Map<String, dynamic> input = <String, dynamic>{
        'offerId': 'off-rt',
        'productName': 'Bag',
        'listedPrice': 50,
        'offerPrice': 40,
        'accepted': true,
        'cancelled': false,
      };

      final Map<String, dynamic> output = ChatOfferResponse.fromJson(
        input,
      ).toJson();

      expect(output, input);
    });

    test('fromJson → toJson is identity for all-null', () {
      final Map<String, dynamic> input = <String, dynamic>{
        'offerId': null,
        'productName': null,
        'listedPrice': null,
        'offerPrice': null,
        'accepted': null,
        'cancelled': null,
      };

      final Map<String, dynamic> output = ChatOfferResponse.fromJson(
        input,
      ).toJson();

      expect(output, input);
    });
  });
}
