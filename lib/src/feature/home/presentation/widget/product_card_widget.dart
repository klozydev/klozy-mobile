import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klozy/src/app/wishlist/wishlist_cubit.dart';
import 'package:klozy/src/core/account/account_gate.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/core/navigation/safe_navigation.dart';
import 'package:klozy/src/design/components/ds_product_card.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/product/entity/product.dart';
import 'package:klozy/src/router/app_router.dart';

/// A feed/wishlist product card bound to the global [WishlistCubit] for its
/// heart state.
class ProductCardWidget extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCardWidget({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool liked = context.select<WishlistCubit, bool>(
      (WishlistCubit c) => c.state.contains(product.id),
    );
    return DSProductCard(
      title: product.title,
      meta: product.meta,
      price: context.l10N.product_price_amount(product.price.toInt()),
      likes: product.likes,
      badge: product.isNewWithTags ? context.l10N.home_product_badge_new : null,
      isLiked: liked,
      imageUrl: product.coverImageUrl,
      onTap:
          onTap ?? () => context.router.pushSafe(ProductRoute(id: product.id)),
      onLikeChanged: (_) => locator<AccountGate>().guard(
        context,
        onAllowed: () => context.read<WishlistCubit>().toggle(product.id),
      ),
    );
  }
}
