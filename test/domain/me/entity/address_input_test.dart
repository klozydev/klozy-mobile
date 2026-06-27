import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/me/entity/address_input.dart';

void main() {
  group('AddressInput', () {
    const AddressInput full = AddressInput(
      line1: 'Marina Gate 1',
      city: 'Dubai',
      emirate: 'Dubai',
      line2: 'Apt 5B',
      area: 'Dubai Marina',
      country: 'United Arab Emirates',
      label: 'Home',
      recipientName: 'Alice',
      phone: '+971501234567',
    );

    test('getters return constructor values', () {
      expect(full.line1, 'Marina Gate 1');
      expect(full.city, 'Dubai');
      expect(full.emirate, 'Dubai');
      expect(full.line2, 'Apt 5B');
      expect(full.area, 'Dubai Marina');
      expect(full.country, 'United Arab Emirates');
      expect(full.label, 'Home');
      expect(full.recipientName, 'Alice');
      expect(full.phone, '+971501234567');
    });

    test('optional fields default to null / default country', () {
      const AddressInput minimal = AddressInput(
        line1: 'Test',
        city: 'Dubai',
        emirate: 'Dubai',
      );
      expect(minimal.line2, isNull);
      expect(minimal.area, isNull);
      expect(minimal.country, 'United Arab Emirates');
      expect(minimal.label, isNull);
      expect(minimal.recipientName, isNull);
      expect(minimal.phone, isNull);
    });

    test('toJson includes required fields', () {
      final Map<String, dynamic> json = full.toJson();
      expect(json['line1'], 'Marina Gate 1');
      expect(json['city'], 'Dubai');
      expect(json['emirate'], 'Dubai');
      expect(json['country'], 'United Arab Emirates');
    });

    test('toJson includes optional fields when non-null and non-empty', () {
      final Map<String, dynamic> json = full.toJson();
      expect(json['line2'], 'Apt 5B');
      expect(json['area'], 'Dubai Marina');
      expect(json['label'], 'Home');
      expect(json['recipientName'], 'Alice');
      expect(json['phone'], '+971501234567');
    });

    test('toJson omits optional fields when null', () {
      const AddressInput minimal = AddressInput(
        line1: 'Test',
        city: 'Dubai',
        emirate: 'Dubai',
      );
      final Map<String, dynamic> json = minimal.toJson();
      expect(json.containsKey('line2'), isFalse);
      expect(json.containsKey('area'), isFalse);
      expect(json.containsKey('label'), isFalse);
      expect(json.containsKey('recipientName'), isFalse);
      expect(json.containsKey('phone'), isFalse);
    });

    test('toJson omits optional fields when empty string', () {
      const AddressInput emptyOptionals = AddressInput(
        line1: 'Test',
        city: 'Dubai',
        emirate: 'Dubai',
        line2: '',
        area: '',
        label: '',
        recipientName: '',
        phone: '',
      );
      final Map<String, dynamic> json = emptyOptionals.toJson();
      expect(json.containsKey('line2'), isFalse);
      expect(json.containsKey('area'), isFalse);
      expect(json.containsKey('label'), isFalse);
      expect(json.containsKey('recipientName'), isFalse);
      expect(json.containsKey('phone'), isFalse);
    });

    test('two instances with same fields are equal', () {
      const AddressInput other = AddressInput(
        line1: 'Marina Gate 1',
        city: 'Dubai',
        emirate: 'Dubai',
        line2: 'Apt 5B',
        area: 'Dubai Marina',
        country: 'United Arab Emirates',
        label: 'Home',
        recipientName: 'Alice',
        phone: '+971501234567',
      );
      expect(full, equals(other));
      expect(full.hashCode, equals(other.hashCode));
    });

    test('instances with different line1 are not equal', () {
      const AddressInput other = AddressInput(
        line1: 'Different St',
        city: 'Dubai',
        emirate: 'Dubai',
      );
      expect(full, isNot(equals(other)));
    });
  });
}
