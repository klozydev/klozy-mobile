import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/me/entity/address.dart';

void main() {
  group('Address', () {
    const Address address = Address(
      id: 'addr-1',
      label: 'Home',
      recipientName: 'Alice',
      phone: '+971501234567',
      line1: 'Marina Gate 1',
      line2: 'Apt 5B',
      area: 'Dubai Marina',
      city: 'Dubai',
      emirate: 'Dubai',
      country: 'United Arab Emirates',
      isDefault: true,
    );

    test('getters return constructor values', () {
      expect(address.id, 'addr-1');
      expect(address.label, 'Home');
      expect(address.recipientName, 'Alice');
      expect(address.phone, '+971501234567');
      expect(address.line1, 'Marina Gate 1');
      expect(address.line2, 'Apt 5B');
      expect(address.area, 'Dubai Marina');
      expect(address.city, 'Dubai');
      expect(address.emirate, 'Dubai');
      expect(address.country, 'United Arab Emirates');
      expect(address.isDefault, isTrue);
    });

    test('summary returns comma-joined non-null non-empty parts', () {
      expect(address.summary, 'Marina Gate 1, Dubai Marina, Dubai, Dubai');
    });

    test('summary omits null parts', () {
      const Address noArea = Address(
        id: 'a2',
        line1: 'Jumeirah Rd',
        city: 'Dubai',
        emirate: 'Dubai',
      );
      expect(noArea.summary, 'Jumeirah Rd, Dubai, Dubai');
    });

    test('title returns label when non-empty', () {
      expect(address.title, 'Home');
    });

    test('title falls back to city when label is null', () {
      const Address noLabel = Address(
        id: 'a3',
        line1: 'Business Bay',
        city: 'Dubai',
        emirate: 'Dubai',
      );
      expect(noLabel.title, 'Dubai');
    });

    test('title falls back to city when label is empty string', () {
      const Address emptyLabel = Address(
        id: 'a4',
        label: '',
        line1: 'Business Bay',
        city: 'Abu Dhabi',
        emirate: 'Abu Dhabi',
      );
      expect(emptyLabel.title, 'Abu Dhabi');
    });

    test('optional fields default to null / false', () {
      const Address minimal = Address(
        id: 'a5',
        line1: 'Test',
        city: 'Dubai',
        emirate: 'Dubai',
      );
      expect(minimal.label, isNull);
      expect(minimal.recipientName, isNull);
      expect(minimal.phone, isNull);
      expect(minimal.line2, isNull);
      expect(minimal.area, isNull);
      expect(minimal.country, 'United Arab Emirates');
      expect(minimal.isDefault, isFalse);
    });

    test('two instances with same fields are equal', () {
      const Address other = Address(
        id: 'addr-1',
        label: 'Home',
        recipientName: 'Alice',
        phone: '+971501234567',
        line1: 'Marina Gate 1',
        line2: 'Apt 5B',
        area: 'Dubai Marina',
        city: 'Dubai',
        emirate: 'Dubai',
        country: 'United Arab Emirates',
        isDefault: true,
      );
      expect(address, equals(other));
      expect(address.hashCode, equals(other.hashCode));
    });

    test('instances with different id are not equal', () {
      const Address other = Address(
        id: 'addr-X',
        line1: 'Test',
        city: 'Dubai',
        emirate: 'Dubai',
      );
      expect(address, isNot(equals(other)));
    });
  });
}
