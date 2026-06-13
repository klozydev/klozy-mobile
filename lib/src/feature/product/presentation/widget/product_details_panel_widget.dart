import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';
import 'package:klozy/src/domain/product/entity/product_detail.dart';
import 'package:klozy/src/feature/chat/entry/chat_launcher.dart';
import 'package:klozy/src/feature/product/presentation/widget/product_detail_meta_row_widget.dart';
import 'package:klozy/src/feature/product/presentation/widget/product_seller_card_widget.dart';
import 'package:klozy/src/router/app_router.dart';

class ProductDetailsPanelWidget extends StatelessWidget {
  final ProductDetail detail;
  final bool isOwner;

  const ProductDetailsPanelWidget({
    super.key,
    required this.detail,
    required this.isOwner,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: DSColor.surface,
      child: Padding(
        padding: const EdgeInsets.all(DSSpacing.s),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ProductSellerCardWidget(
              seller: detail.seller,
              isOwner: isOwner,
              detail: isOwner ? null : detail,
              onMessage: () => context.openChatWith(detail.seller.id),
              onTap: isOwner
                  ? null
                  : () => context.router.push(
                      UserProfileRoute(userId: detail.seller.id),
                    ),
            ),
            const SizedBox(height: DSSpacing.s),
            ProductDetailMetaRowWidget(product: detail),
            if (detail.description.isNotEmpty) ...<Widget>[
              const SizedBox(height: DSSpacing.s),
              Text(
                detail.description,
                style: const TextStyle(
                  fontFamily: dsFontFamily,
                  fontSize: DSFontSize.bodyLarge,
                  height: 1.7,
                  color: DSColor.onSurface65,
                ),
              ),
            ],
            const SizedBox(height: DSSpacing.xxxl * 2),
          ],
        ),
      ),
    );
  }
}
