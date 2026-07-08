import 'package:flutter/material.dart';
import 'package:klozy/src/core/util/relative_time_formatter.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
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

    final String? postedLabel =
        product.postedLabel ??
        (product.postedAt != null
            ? RelativeTimeFormatter.format(context, product.postedAt!)
            : null);
    if (postedLabel != null) {
      parts.add(_MetaChip(icon: Icons.schedule, label: postedLabel));
    }

    if (product.location != null) {
      if (parts.isNotEmpty) {
        parts.add(const SizedBox(width: DSSpacing.xxs));
      }
      parts.add(
        _MetaChip(icon: Icons.location_on_outlined, label: product.location!),
      );
    }

    if (parts.isEmpty) return const SizedBox.shrink();

    return Row(mainAxisSize: MainAxisSize.min, children: parts);
  }
}

/// Boxed meta chip (design: bg onSurface07, hairline border, radius 12,
/// icon 14 + text 13 medium).
class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: DSColor.onSurface07,
        borderRadius: BorderRadius.circular(DSBorderRadius.image),
        border: Border.all(color: DSColor.onSurface10, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: DSColor.onSurface65),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              fontFamily: dsFontFamily,
              fontSize: DSFontSize.bodyMedium,
              fontWeight: DSFontWeight.medium,
              color: DSColor.onSurface85,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
