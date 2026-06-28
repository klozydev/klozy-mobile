import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/chat/data/response/chat_purchase_response.dart';

void main() {
  // ── fromJson ────────────────────────────────────────────────────────────────

  group('ChatPurchaseResponse.fromJson', () {
    test('parses all fields', () {
      final ChatPurchaseResponse r = ChatPurchaseResponse.fromJson(
        <String, dynamic>{
          'orderId': 'ord-1',
          'productName': 'Sneakers',
          'amount': 120,
        },
      );

      expect(r.orderId, 'ord-1');
      expect(r.productName, 'Sneakers');
      expect(r.amount, 120);
    });

    test('parses all fields as null when absent', () {
      final ChatPurchaseResponse r = ChatPurchaseResponse.fromJson(
        <String, dynamic>{},
      );

      expect(r.orderId, isNull);
      expect(r.productName, isNull);
      expect(r.amount, isNull);
    });

    test('parses decimal amount', () {
      final ChatPurchaseResponse r = ChatPurchaseResponse.fromJson(
        <String, dynamic>{'amount': 99.99},
      );

      expect(r.amount, 99.99);
    });
  });

  // ── toJson ──────────────────────────────────────────────────────────────────

  group('ChatPurchaseResponse.toJson', () {
    test('serialises all fields', () {
      const ChatPurchaseResponse r = ChatPurchaseResponse(
        orderId: 'ord-2',
        productName: 'Jacket',
        amount: 200,
      );

      final Map<String, dynamic> json = r.toJson();

      expect(json['orderId'], 'ord-2');
      expect(json['productName'], 'Jacket');
      expect(json['amount'], 200);
    });

    test('serialises null fields as null', () {
      const ChatPurchaseResponse r = ChatPurchaseResponse();

      final Map<String, dynamic> json = r.toJson();

      expect(json['orderId'], isNull);
      expect(json['productName'], isNull);
      expect(json['amount'], isNull);
    });
  });

  // ── round-trip ──────────────────────────────────────────────────────────────

  group('ChatPurchaseResponse round-trip', () {
    test('fromJson → toJson is identity for all fields', () {
      final Map<String, dynamic> input = <String, dynamic>{
        'orderId': 'ord-rt',
        'productName': 'Watch',
        'amount': 350,
      };

      final Map<String, dynamic> output = ChatPurchaseResponse.fromJson(
        input,
      ).toJson();

      expect(output, input);
    });

    test('fromJson → toJson is identity for all-null', () {
      final Map<String, dynamic> input = <String, dynamic>{
        'orderId': null,
        'productName': null,
        'amount': null,
      };

      final Map<String, dynamic> output = ChatPurchaseResponse.fromJson(
        input,
      ).toJson();

      expect(output, input);
    });
  });
}
