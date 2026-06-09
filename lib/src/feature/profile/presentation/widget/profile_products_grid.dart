import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/domain/product/entity/product.dart';
import 'package:klozy/src/feature/home/presentation/widget/product_card_widget.dart';
import 'package:klozy/src/feature/profile/presentation/widget/profile_tab_empty.dart';

class ProfileProductsGrid extends StatelessWidget {
  final List<Product> products;

  const ProfileProductsGrid({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return ProfileTabEmpty(
        icon: Icons.checkroom_outlined,
        label: context.l10N.profile_no_listings,
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.56,
      ),
      itemCount: products.length,
      itemBuilder: (BuildContext context, int i) =>
          ProductCardWidget(product: products[i]),
    );
  }
}
