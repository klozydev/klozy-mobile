import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';
import 'package:klozy/src/domain/product/entity/product_detail.dart';

class ProductDetailMetaRowWidget extends StatelessWidget {
  final ProductDetail product;

  const ProductDetailMetaRowWidget({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final List<Widget> parts = <Widget>[];

    if (product.postedLabel != null) {
      parts.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.schedule, size: 13, color: DSColor.onSurface45),
            const SizedBox(width: DSSpacing.xxxs),
            Text(
              product.postedLabel!,
              style: const TextStyle(
                fontFamily: dsFontFamily,
                fontSize: DSFontSize.bodySmall,
                color: DSColor.onSurface45,
              ),
            ),
          ],
        ),
      );
    }

    if (product.location != null) {
      if (parts.isNotEmpty) {
        parts.add(const SizedBox(width: DSSpacing.xs));
      }
      parts.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.location_on_outlined,
              size: 13,
              color: DSColor.onSurface45,
            ),
            const SizedBox(width: DSSpacing.xxxs),
            Text(
              product.location!,
              style: const TextStyle(
                fontFamily: dsFontFamily,
                fontSize: DSFontSize.bodySmall,
                color: DSColor.onSurface45,
              ),
            ),
          ],
        ),
      );
    }

    if (parts.isEmpty) return const SizedBox.shrink();

    return Row(children: parts);
  }
}
