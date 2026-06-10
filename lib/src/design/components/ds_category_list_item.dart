import 'package:flutter/material.dart';
import 'package:klozy/src/design/components/ds_list_item.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_category.dart';

/// Single row in the category drill-down list. Shows a chevron for parent
/// nodes and a check icon for leaf nodes.
class DSCategoryListItem extends StatelessWidget {
  final CatalogCategory category;
  final VoidCallback onTap;

  const DSCategoryListItem({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DSListItem(
      title: category.label,
      trailing: category.hasChildren
          ? const Icon(
              Icons.chevron_right,
              color: DSColor.onSurface60,
              size: 20,
            )
          : const Icon(
              Icons.check_circle_outline_rounded,
              color: DSColor.primary,
              size: 20,
            ),
      onTap: onTap,
    );
  }
}
