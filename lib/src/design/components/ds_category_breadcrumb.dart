import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_category.dart';

/// Breadcrumb bar for the category drill-down picker. Each level is tappable
/// and fires [onLevelTapped] with the index to jump back to.
class DSCategoryBreadcrumb extends StatelessWidget {
  final List<CatalogCategory> path;
  final String rootLabel;
  final void Function(int levelIndex) onLevelTapped;

  const DSCategoryBreadcrumb({
    super.key,
    required this.path,
    required this.rootLabel,
    required this.onLevelTapped,
  });

  @override
  Widget build(BuildContext context) {
    final segments = <_BreadcrumbSegment>[
      _BreadcrumbSegment(label: rootLabel, index: -1),
      for (var i = 0; i < path.length; i++)
        _BreadcrumbSegment(label: path[i].label, index: i),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: DSSpacing.xs, top: DSSpacing.xxs),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            for (var i = 0; i < segments.length; i++) ...<Widget>[
              if (i > 0)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: DSSpacing.xxxs),
                  child: Text(
                    '›',
                    style: TextStyle(
                      fontFamily: dsFontFamily,
                      fontSize: DSFontSize.bodyMedium,
                      color: DSColor.onSurface35,
                    ),
                  ),
                ),
              GestureDetector(
                onTap: () => onLevelTapped(segments[i].index),
                child: Text(
                  segments[i].label,
                  style: TextStyle(
                    fontFamily: dsFontFamily,
                    fontSize: DSFontSize.bodyMedium,
                    fontWeight: i == segments.length - 1
                        ? DSFontWeight.semiBold
                        : DSFontWeight.regular,
                    color: i == segments.length - 1
                        ? DSColor.onSurface
                        : DSColor.onSurface60,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BreadcrumbSegment {
  final String label;

  /// -1 = root level, 0..n = path index.
  final int index;

  const _BreadcrumbSegment({required this.label, required this.index});
}
