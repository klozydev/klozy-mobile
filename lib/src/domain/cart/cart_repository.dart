import 'package:klozy/src/domain/cart/entity/cart.dart';

/// The cart (`/v1/cart`).
abstract class CartRepository {
  /// `GET /v1/cart` — items grouped into per-seller buckets.
  Future<Cart> getCart();

  /// `POST /v1/cart/items` — add a product to the cart.
  Future<void> addItem(String productId);

  /// `DELETE /v1/cart/items/{productId}`.
  Future<void> removeItem(String productId);
}
