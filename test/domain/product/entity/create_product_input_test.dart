import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/product/entity/create_product_input.dart';

void main() {
  group('CreateProductInput', () {
    const CreateProductInput full = CreateProductInput(
      title: 'Blue Jacket',
      price: 500,
      conditionId: 'cond-1',
      categoryId: 'cat-1',
      description: 'Excellent condition.',
      size: 'M',
      brandId: 'brand-1',
      brandName: 'Zara',
      images: <String>['https://example.com/img1.jpg'],
      location: 'Dubai',
      translations: <String, dynamic>{
        'fr': <String, dynamic>{'title': 'Veste bleue'},
      },
    );

    test('getters return constructor values', () {
      expect(full.title, 'Blue Jacket');
      expect(full.price, 500);
      expect(full.conditionId, 'cond-1');
      expect(full.categoryId, 'cat-1');
      expect(full.description, 'Excellent condition.');
      expect(full.size, 'M');
      expect(full.brandId, 'brand-1');
      expect(full.brandName, 'Zara');
      expect(full.images, <String>['https://example.com/img1.jpg']);
      expect(full.location, 'Dubai');
      expect(full.translations, isNotNull);
    });

    test('optional fields default to null / empty', () {
      const CreateProductInput minimal = CreateProductInput(
        title: 'Bag',
        price: 100,
        conditionId: 'cond-1',
        categoryId: 'cat-2',
      );
      expect(minimal.description, isNull);
      expect(minimal.size, isNull);
      expect(minimal.brandId, isNull);
      expect(minimal.brandName, isNull);
      expect(minimal.images, isEmpty);
      expect(minimal.location, isNull);
      expect(minimal.translations, isNull);
    });

    test('toJson includes required fields', () {
      final Map<String, dynamic> json = full.toJson();
      expect(json['title'], 'Blue Jacket');
      expect(json['price'], 500);
      expect(json['conditionId'], 'cond-1');
      expect(json['categoryId'], 'cat-1');
    });

    test('toJson includes optional fields when non-null and non-empty', () {
      final Map<String, dynamic> json = full.toJson();
      expect(json['description'], 'Excellent condition.');
      expect(json['size'], 'M');
      expect(json['brandId'], 'brand-1');
      expect(json['brandName'], 'Zara');
      expect(json['images'], <String>['https://example.com/img1.jpg']);
      expect(json['location'], 'Dubai');
      expect(json['translations'], isNotNull);
    });

    test('toJson omits description when null', () {
      const CreateProductInput minimal = CreateProductInput(
        title: 'Bag',
        price: 100,
        conditionId: 'cond-1',
        categoryId: 'cat-2',
      );
      final Map<String, dynamic> json = minimal.toJson();
      expect(json.containsKey('description'), isFalse);
    });

    test('toJson omits images when empty', () {
      const CreateProductInput minimal = CreateProductInput(
        title: 'Bag',
        price: 100,
        conditionId: 'cond-1',
        categoryId: 'cat-2',
      );
      final Map<String, dynamic> json = minimal.toJson();
      expect(json.containsKey('images'), isFalse);
    });

    test('toJson omits size when empty string', () {
      const CreateProductInput emptySize = CreateProductInput(
        title: 'Bag',
        price: 100,
        conditionId: 'cond-1',
        categoryId: 'cat-2',
        size: '',
      );
      final Map<String, dynamic> json = emptySize.toJson();
      expect(json.containsKey('size'), isFalse);
    });
  });
}
