import 'package:klozy/src/core/pagination/paginated_list.dart';
import 'package:klozy/src/domain/product/entity/product.dart';

/// Saved products (`/v1/me/wishlist`).
abstract class WishlistRepository {
  /// Product ids the user has saved (seeds the global [WishlistCubit]).
  Future<Set<String>> getWishlistProductIds();

  Future<PaginatedList<Product>> getWishlistProducts({
    int page = 1,
    int limit = 20,
  });

  Future<void> add(String productId);

  Future<void> remove(String productId);
}
