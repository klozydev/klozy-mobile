import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/chat/domain/entity/purchase_data.dart';

void main() {
  group('PurchaseData', () {
    const PurchaseData data = PurchaseData(
      productName: 'White Sneakers',
      amount: 250,
    );

    test('getters return constructor values', () {
      expect(data.productName, 'White Sneakers');
      expect(data.amount, 250);
    });

    test('two instances with same fields are equal', () {
      const PurchaseData other = PurchaseData(
        productName: 'White Sneakers',
        amount: 250,
      );
      expect(data, equals(other));
      expect(data.hashCode, equals(other.hashCode));
    });

    test('instances with different productName are not equal', () {
      const PurchaseData other = PurchaseData(
        productName: 'Blue Jacket',
        amount: 250,
      );
      expect(data, isNot(equals(other)));
    });
  });
}
