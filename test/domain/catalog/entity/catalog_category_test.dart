import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_category.dart';

void main() {
  group('CatalogCategory', () {
    const CatalogCategory category = CatalogCategory(
      id: 'cat-1',
      label: 'Shoes',
      hasChildren: true,
    );

    test('getters return constructor values', () {
      expect(category.id, 'cat-1');
      expect(category.label, 'Shoes');
      expect(category.hasChildren, isTrue);
    });

    test('hasChildren defaults to false', () {
      const CatalogCategory leaf = CatalogCategory(id: 'cat-2', label: 'Boots');
      expect(leaf.hasChildren, isFalse);
    });

    test('two instances with same fields are equal', () {
      const CatalogCategory other = CatalogCategory(
        id: 'cat-1',
        label: 'Shoes',
        hasChildren: true,
      );
      expect(category, equals(other));
      expect(category.hashCode, equals(other.hashCode));
    });

    test('instances with different id are not equal', () {
      const CatalogCategory other = CatalogCategory(
        id: 'cat-X',
        label: 'Shoes',
      );
      expect(category, isNot(equals(other)));
    });
  });
}
