import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_app_bar.dart';
import 'package:klozy/src/design/components/ds_category_tree_picker.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/catalog/catalog_repository.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_category.dart';

@RoutePage()
class SellCategoryPage extends StatelessWidget implements AutoRouteWrapper {
  /// When set, the drill-down is scoped to this root (design: pick a main
  /// category — Women/Men/Kids — first, then choose a subcategory within it).
  final CatalogCategory? parent;

  const SellCategoryPage({super.key, this.parent});

  @override
  Widget wrappedRoute(BuildContext context) => this;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColor.surface,
      appBar: DSAppBar(
        title: context.l10N.categoryPickerTitle,
        backType: BackType.push,
      ),
      body: SafeArea(
        child: DSCategoryTreePicker(
          repo: locator<CatalogRepository>(),
          showBreadcrumb: true,
          initialParent: parent,
          onLeafSelected: (PickedCategory picked) {
            context.router.maybePop(picked);
          },
        ),
      ),
    );
  }
}
