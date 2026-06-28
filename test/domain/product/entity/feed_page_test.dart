import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/product/entity/feed_page.dart';
import 'package:klozy/src/domain/product/entity/product.dart';

void main() {
  group('FeedPage', () {
    const Product product = Product(id: 'p1', title: 'Sneakers', price: 200);

    const FeedPage page = FeedPage(
      data: <Product>[product],
      pickedForYou: <String>['Dresses', 'Tops'],
    );

    test('getters return constructor values', () {
      expect(page.data, <Product>[product]);
      expect(page.pickedForYou, <String>['Dresses', 'Tops']);
    });

    test('pickedForYou defaults to empty list', () {
      const FeedPage minimal = FeedPage(data: <Product>[]);
      expect(minimal.pickedForYou, isEmpty);
    });

    test('data holds the products', () {
      expect(page.data, hasLength(1));
      expect(page.data.first.id, 'p1');
    });
  });
}
