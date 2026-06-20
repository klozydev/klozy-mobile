import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_attribute_chip.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';
import 'package:klozy/src/domain/product/entity/product_detail.dart';

class ProductTitleBlockWidget extends StatelessWidget {
  final ProductDetail product;

  const ProductTitleBlockWidget({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Owner-only "Your listing" pill above the title (design: gold glass
          // chip, accent text).
          if (product.isOwner)
            Container(
              margin: const EdgeInsets.only(bottom: DSSpacing.xs),
              padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.xs,
                vertical: DSSpacing.xxxs,
              ),
              decoration: BoxDecoration(
                color: DSColor.primary.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(DSBorderRadius.chip),
              ),
              child: Text(
                context.l10N.product_your_listing,
                style: const TextStyle(
                  fontFamily: dsFontFamily,
                  fontSize: DSFontSize.bodySmall,
                  fontWeight: DSFontWeight.semiBold,
                  color: DSColor.primary,
                ),
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: dsFontFamily,
                    fontSize: DSFontSize.headlineLarge,
                    fontWeight: DSFontWeight.bold,
                    color: Colors.white,
                    height: 1.25,
                    shadows: <Shadow>[
                      Shadow(color: Color(0x99000000), blurRadius: 6),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: DSSpacing.s),
              Padding(
                padding: const EdgeInsets.only(top: DSSpacing.xxxs),
                child: Text(
                  context.l10N.product_price_amount(product.price.toInt()),
                  style: const TextStyle(
                    fontFamily: dsFontFamily,
                    fontSize: DSFontSize.headlineLarge,
                    fontWeight: DSFontWeight.bold,
                    color: DSColor.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.xs),
          // Chips mirror the design order: brand · size · condition.
          Wrap(
            spacing: DSSpacing.xxs,
            runSpacing: DSSpacing.xxs,
            children: <Widget>[
              if (product.brand.isNotEmpty)
                DSAttributeChip(label: product.brand),
              if (product.size.isNotEmpty) DSAttributeChip(label: product.size),
              if (product.conditionLabel != null)
                DSAttributeChip(label: product.conditionLabel!),
            ],
          ),
        ],
      ),
    );
  }
}
