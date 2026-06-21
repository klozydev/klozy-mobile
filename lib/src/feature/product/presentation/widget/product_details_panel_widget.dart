import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';
import 'package:klozy/src/domain/product/entity/product_detail.dart';
import 'package:klozy/src/feature/chat/entry/chat_launcher.dart';
import 'package:klozy/src/feature/product/presentation/widget/product_detail_meta_row_widget.dart';
import 'package:klozy/src/feature/product/presentation/widget/product_owner_stats_widget.dart';
import 'package:klozy/src/feature/product/presentation/widget/product_seller_card_widget.dart';
import 'package:klozy/src/router/app_router.dart';

class ProductDetailsPanelWidget extends StatelessWidget {
  final ProductDetail detail;
  final bool isOwner;

  /// Inline "Report this listing" action (non-owner only).
  final VoidCallback onReport;

  const ProductDetailsPanelWidget({
    super.key,
    required this.detail,
    required this.isOwner,
    required this.onReport,
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
              onMessage: () => context.openChatWith(
                detail.seller.id,
                displayName: detail.seller.displayName,
                avatarUrl: detail.seller.avatarUrl,
              ),
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
            // Owner sees performance stats; everyone else sees an inline report.
            if (isOwner)
              ProductOwnerStatsWidget(detail: detail)
            else
              Padding(
                padding: const EdgeInsets.only(top: 18, bottom: 8),
                child: InkWell(
                  onTap: onReport,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(
                        Icons.flag_outlined,
                        size: 15,
                        color: DSColor.onSurface45,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        context.l10N.product_report_this_listing,
                        style: const TextStyle(
                          fontFamily: dsFontFamily,
                          fontSize: DSFontSize.bodyMedium,
                          color: DSColor.onSurface45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: DSSpacing.xxxl * 2),
          ],
        ),
      ),
    );
  }
}
