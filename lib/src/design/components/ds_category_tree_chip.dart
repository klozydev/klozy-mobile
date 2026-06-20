import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_category.dart';

/// A single drill-down node rendered as a pill chip (Filters-sheet layout).
/// Parent nodes show a trailing chevron; the picked leaf renders selected.
class DSCategoryTreeChip extends StatelessWidget {
  final CatalogCategory category;
  final bool selected;
  final VoidCallback onTap;

  /// Backend facet count for this node (search filter). Null hides the badge.
  final int? count;

  const DSCategoryTreeChip({
    super.key,
    required this.category,
    required this.selected,
    required this.onTap,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    final Color content = selected ? DSColor.surface : DSColor.onSurface;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? DSColor.primary : DSColor.onSurface07,
          borderRadius: BorderRadius.circular(DSBorderRadius.chip),
          border: selected
              ? null
              : Border.all(color: DSColor.onSurface15, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              category.label,
              style: TextStyle(
                fontFamily: dsFontFamily,
                fontSize: DSFontSize.bodyMedium,
                fontWeight: DSFontWeight.medium,
                color: content,
              ),
            ),
            if (count != null) ...<Widget>[
              const SizedBox(width: 6),
              Text(
                '$count',
                style: TextStyle(
                  fontFamily: dsFontFamily,
                  fontSize: DSFontSize.bodySmall,
                  fontWeight: DSFontWeight.medium,
                  color: selected ? DSColor.surface : DSColor.onSurface45,
                ),
              ),
            ],
            if (category.hasChildren) ...<Widget>[
              const SizedBox(width: 6),
              Icon(Icons.chevron_right, size: 14, color: content),
            ],
          ],
        ),
      ),
    );
  }
}
