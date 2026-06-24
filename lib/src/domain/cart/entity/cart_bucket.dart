import 'package:equatable/equatable.dart';
import 'package:klozy/src/domain/cart/entity/cart_bundle.dart';
import 'package:klozy/src/domain/cart/entity/cart_item.dart';

/// One seller's items in the cart. A seller can have several active offers:
/// single-item offers (on a [CartItem]) and bundle offers (in [bundles]).
class CartBucket extends Equatable {
  final String sellerId;
  final String sellerName;
  final String? sellerAvatar;
  final bool isPro;
  final List<CartItem> items;
  final num subtotal;
  final List<CartBundle> bundles;

  /// True when there are >= 2 standalone items that could be bundled.
  final bool canBundle;

  const CartBucket({
    required this.sellerId,
    required this.items,
    required this.subtotal,
    this.sellerName = '',
    this.sellerAvatar,
    this.isPro = false,
    this.bundles = const <CartBundle>[],
    this.canBundle = false,
  });

  /// Product ids of standalone items (no item offer, not in a bundle) — the set
  /// a new bundle offer would cover.
  List<String> get standaloneProductIds => items
      .where((CartItem i) => !i.inBundle && !i.hasItemOffer)
      .map((CartItem i) => i.productId)
      .toList();

  @override
  List<Object?> get props => [
    sellerId,
    sellerName,
    sellerAvatar,
    isPro,
    items,
    subtotal,
    bundles,
    canBundle,
  ];
}
