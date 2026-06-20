import 'package:flutter/material.dart';
import 'package:klozy/src/design/components/ds_list_item.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_category.dart';

/// Single row in the category drill-down list. Shows a chevron for parent
/// nodes and a check icon for leaf nodes. When [count] is provided (search
/// filter, fed by backend facets), the number of matching items is shown.
class DSCategoryListItem extends StatelessWidget {
  final CatalogCategory category;
  final VoidCallback onTap;
  final int? count;

  const DSCategoryListItem({
    super.key,
    required this.category,
    required this.onTap,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    final Icon icon = category.hasChildren
        ? const Icon(Icons.chevron_right, color: DSColor.onSurface60, size: 20)
        : const Icon(
            Icons.check_circle_outline_rounded,
            color: DSColor.primary,
            size: 20,
          );
    return DSListItem(
      title: category.label,
      trailing: count == null
          ? icon
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  '$count',
                  style: const TextStyle(
                    fontFamily: dsFontFamily,
                    fontSize: DSFontSize.bodyMedium,
                    color: DSColor.onSurface45,
                  ),
                ),
                const SizedBox(width: 6),
                icon,
              ],
            ),
      onTap: onTap,
    );
  }
}
