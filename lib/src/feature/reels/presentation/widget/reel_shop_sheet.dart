import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/core/navigation/safe_navigation.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/components/ds_network_image/ds_network_image.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/product/entity/product.dart';
import 'package:klozy/src/feature/reels/domain/reels_repository.dart';
import 'package:klozy/src/router/app_router.dart';

/// "Shop the look" sheet body — the products tagged in a reel, each with a
/// wishlist toggle.
class ReelShopSheet extends StatefulWidget {
  final String reelId;

  const ReelShopSheet({super.key, required this.reelId});

  @override
  State<ReelShopSheet> createState() => _ReelShopSheetState();
}

class _ReelShopSheetState extends State<ReelShopSheet> {
  late final Future<List<Product>> _future = locator<ReelsRepository>()
      .shopTheLook(widget.reelId);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<List<Product>> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(height: 120, child: DSLoader());
        }
        final items = snapshot.data ?? const <Product>[];
        if (items.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                context.l10N.reels_no_tagged_items,
                style: const TextStyle(
                  fontFamily: dsFontFamily,
                  color: DSColor.onSurface45,
                ),
              ),
            ),
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: items.map((Product p) => _row(context, p)).toList(),
        );
      },
    );
  }

  Widget _row(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () => context.router.pushSafe(ProductRoute(id: product.id)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: DSColor.card,
          borderRadius: BorderRadius.circular(DSBorderRadius.cardSmall),
        ),
        child: Row(
          children: <Widget>[
            DSNetworkImage(
              imageUrl: product.coverImageUrl,
              width: 56,
              height: 56,
              borderRadius: DSBorderRadius.light,
              fallback: const ColoredBox(color: DSColor.lowBlack),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: dsFontFamily,
                      fontSize: DSFontSize.bodyMedium,
                      fontWeight: DSFontWeight.medium,
                      color: DSColor.onSurface,
                    ),
                  ),
                  Text(
                    product.meta,
                    style: const TextStyle(
                      fontFamily: dsFontFamily,
                      fontSize: DSFontSize.bodySmall,
                      color: DSColor.onSurface45,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.l10N.cart_price_dhs(product.price.toInt()),
                    style: const TextStyle(
                      fontFamily: dsFontFamily,
                      fontSize: DSFontSize.bodyMedium,
                      fontWeight: DSFontWeight.bold,
                      color: DSColor.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: DSColor.onSurface35,
            ),
          ],
        ),
      ),
    );
  }
}
