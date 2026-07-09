import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';
import 'package:klozy/src/domain/product/entity/product.dart';
import 'package:klozy/src/feature/home/presentation/widget/product_card_widget.dart';
import 'package:klozy/src/feature/profile/presentation/widget/profile_tab_empty.dart';

/// Sliver form of the Products tab grid, for use inside a `CustomScrollView`
/// so pull-to-refresh and infinite scroll keep working even when the grid is
/// shorter than the viewport. Mirrors `ProfileProductsGrid`'s delegate and
/// card visuals.
class ProfileProductsSliverGrid extends StatelessWidget {
  final List<Product> products;

  const ProfileProductsSliverGrid({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: ProfileTabEmpty(
          icon: Icons.checkroom_outlined,
          label: context.l10N.profile_no_listings,
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        DSSpacing.s,
        DSSpacing.s,
        DSSpacing.s,
        DSSpacing.l,
      ),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.56,
        ),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int i) =>
              ProductCardWidget(product: products[i]),
          childCount: products.length,
        ),
      ),
    );
  }
}
