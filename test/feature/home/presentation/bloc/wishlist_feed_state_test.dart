import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/product/entity/product.dart';
import 'package:klozy/src/feature/home/presentation/bloc/wishlist_feed_state.dart';

void main() {
  group('WishlistFeedLoaded.copyWith', () {
    const base = WishlistFeedLoaded(
      items: <Product>[],
      hasMore: true,
      loadingMore: false,
    );

    test('overrides only loadingMore, preserving items and hasMore', () {
      final updated = base.copyWith(loadingMore: true);
      expect(updated.loadingMore, isTrue);
      expect(updated.hasMore, isTrue);
      expect(updated.items, isEmpty);
    });

    test('without arguments returns an equal value', () {
      expect(base.copyWith(), base);
    });
  });
}
