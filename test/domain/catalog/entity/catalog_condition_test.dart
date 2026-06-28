import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_condition.dart';

void main() {
  group('CatalogCondition', () {
    const CatalogCondition condition = CatalogCondition(
      slug: 'veryGood',
      label: 'Very good',
    );

    test('getters return constructor values', () {
      expect(condition.slug, 'veryGood');
      expect(condition.label, 'Very good');
    });

    test('two instances with same fields are equal', () {
      const CatalogCondition other = CatalogCondition(
        slug: 'veryGood',
        label: 'Very good',
      );
      expect(condition, equals(other));
      expect(condition.hashCode, equals(other.hashCode));
    });

    test('instances with different slug are not equal', () {
      const CatalogCondition other = CatalogCondition(
        slug: 'good',
        label: 'Good',
      );
      expect(condition, isNot(equals(other)));
    });
  });
}
