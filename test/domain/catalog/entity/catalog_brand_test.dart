import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_brand.dart';

void main() {
  group('CatalogBrand', () {
    const CatalogBrand brand = CatalogBrand(id: 'brand-1', name: 'Nike');

    test('getters return constructor values', () {
      expect(brand.id, 'brand-1');
      expect(brand.name, 'Nike');
    });

    test('two instances with same fields are equal', () {
      const CatalogBrand other = CatalogBrand(id: 'brand-1', name: 'Nike');
      expect(brand, equals(other));
      expect(brand.hashCode, equals(other.hashCode));
    });

    test('instances with different id are not equal', () {
      const CatalogBrand other = CatalogBrand(id: 'brand-X', name: 'Nike');
      expect(brand, isNot(equals(other)));
    });
  });
}
