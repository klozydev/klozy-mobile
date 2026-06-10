import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_attribute_chip.dart';
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
        children: <Widget>[
          Text(
            product.title,
            style: const TextStyle(
              fontFamily: dsFontFamily,
              fontSize: DSFontSize.headlineLarge,
              fontWeight: DSFontWeight.bold,
              color: Colors.white,
              shadows: <Shadow>[
                Shadow(color: Color(0x99000000), blurRadius: 6),
              ],
            ),
          ),
          const SizedBox(height: DSSpacing.xxs),
          Text.rich(
            TextSpan(
              text: context.l10N.product_price_amount(product.price.toInt()),
              style: const TextStyle(
                fontFamily: dsFontFamily,
                fontSize: DSFontSize.displayLarge,
                fontWeight: DSFontWeight.bold,
                color: DSColor.primary,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: context.l10N.product_currency_dhs,
                  style: const TextStyle(
                    fontSize: DSFontSize.bodyMedium,
                    fontWeight: DSFontWeight.medium,
                    color: DSColor.onSurface60,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DSSpacing.xs),
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
