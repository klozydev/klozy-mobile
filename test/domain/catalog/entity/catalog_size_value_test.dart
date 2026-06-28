import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_size_value.dart';

void main() {
  group('CatalogSizeValue', () {
    const Map<String, String> systemLabels = <String, String>{
      'EU': '42',
      'US': '9',
      'UK': '8',
    };

    const CatalogSizeValue shoeSizeValue = CatalogSizeValue(
      token: 'eu42',
      label: '42',
      systemLabels: systemLabels,
    );

    const CatalogSizeValue clothingSizeValue = CatalogSizeValue(
      token: 'M',
      label: 'M',
    );

    test('getters return constructor values', () {
      expect(shoeSizeValue.token, 'eu42');
      expect(shoeSizeValue.label, '42');
      expect(shoeSizeValue.systemLabels, systemLabels);
    });

    test('isRegional is true when systemLabels has more than one entry', () {
      expect(shoeSizeValue.isRegional, isTrue);
    });

    test('isRegional is false when systemLabels is null', () {
      expect(clothingSizeValue.isRegional, isFalse);
    });

    test('isRegional is false when systemLabels has only one entry', () {
      const CatalogSizeValue oneSystem = CatalogSizeValue(
        token: 't1',
        label: 'S',
        systemLabels: <String, String>{'EU': 'S'},
      );
      expect(oneSystem.isRegional, isFalse);
    });

    test('labelFor returns correct system label', () {
      expect(shoeSizeValue.labelFor('EU'), '42');
      expect(shoeSizeValue.labelFor('US'), '9');
      expect(shoeSizeValue.labelFor('UK'), '8');
    });

    test('labelFor is case-insensitive (uppercases system key)', () {
      expect(shoeSizeValue.labelFor('eu'), '42');
      expect(shoeSizeValue.labelFor('us'), '9');
    });

    test('labelFor falls back to label for unknown system', () {
      expect(shoeSizeValue.labelFor('JP'), '42');
    });

    test('labelFor falls back to label when systemLabels is null', () {
      expect(clothingSizeValue.labelFor('EU'), 'M');
    });

    test('two instances with same fields are equal', () {
      const CatalogSizeValue other = CatalogSizeValue(
        token: 'eu42',
        label: '42',
        systemLabels: systemLabels,
      );
      expect(shoeSizeValue, equals(other));
      expect(shoeSizeValue.hashCode, equals(other.hashCode));
    });

    test('instances with different token are not equal', () {
      const CatalogSizeValue other = CatalogSizeValue(
        token: 'eu44',
        label: '44',
      );
      expect(shoeSizeValue, isNot(equals(other)));
    });
  });
}
