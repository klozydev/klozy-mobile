import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/checkout/entity/payment_sheet_data.dart';

void main() {
  group('PaymentSheetData', () {
    const PaymentSheetData data = PaymentSheetData(
      clientSecret: 'cs_test_abc',
      ephemeralKey: 'ek_test_xyz',
      customerId: 'cus_123',
      publishableKey: 'pk_test_123',
      amountFils: 25000,
    );

    test('getters return constructor values', () {
      expect(data.clientSecret, 'cs_test_abc');
      expect(data.ephemeralKey, 'ek_test_xyz');
      expect(data.customerId, 'cus_123');
      expect(data.publishableKey, 'pk_test_123');
      expect(data.amountFils, 25000);
    });

    test('amountFils defaults to 0', () {
      const PaymentSheetData minimal = PaymentSheetData(
        clientSecret: 'cs',
        ephemeralKey: 'ek',
        customerId: 'cu',
        publishableKey: 'pk',
      );
      expect(minimal.amountFils, 0);
    });

    test('isValid returns true when all keys are non-empty', () {
      expect(data.isValid, isTrue);
    });

    test('isValid returns false when clientSecret is empty', () {
      const PaymentSheetData invalid = PaymentSheetData(
        clientSecret: '',
        ephemeralKey: 'ek',
        customerId: 'cu',
        publishableKey: 'pk',
      );
      expect(invalid.isValid, isFalse);
    });

    test('isValid returns false when ephemeralKey is empty', () {
      const PaymentSheetData invalid = PaymentSheetData(
        clientSecret: 'cs',
        ephemeralKey: '',
        customerId: 'cu',
        publishableKey: 'pk',
      );
      expect(invalid.isValid, isFalse);
    });

    test('isValid returns false when customerId is empty', () {
      const PaymentSheetData invalid = PaymentSheetData(
        clientSecret: 'cs',
        ephemeralKey: 'ek',
        customerId: '',
        publishableKey: 'pk',
      );
      expect(invalid.isValid, isFalse);
    });

    test('isValid returns false when publishableKey is empty', () {
      const PaymentSheetData invalid = PaymentSheetData(
        clientSecret: 'cs',
        ephemeralKey: 'ek',
        customerId: 'cu',
        publishableKey: '',
      );
      expect(invalid.isValid, isFalse);
    });

    test('two instances with same fields are equal', () {
      const PaymentSheetData other = PaymentSheetData(
        clientSecret: 'cs_test_abc',
        ephemeralKey: 'ek_test_xyz',
        customerId: 'cus_123',
        publishableKey: 'pk_test_123',
        amountFils: 25000,
      );
      expect(data, equals(other));
      expect(data.hashCode, equals(other.hashCode));
    });

    test('instances with different clientSecret are not equal', () {
      const PaymentSheetData other = PaymentSheetData(
        clientSecret: 'cs_different',
        ephemeralKey: 'ek_test_xyz',
        customerId: 'cus_123',
        publishableKey: 'pk_test_123',
      );
      expect(data, isNot(equals(other)));
    });
  });
}
