import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/design/components/ds_app_bar.dart';
import 'package:klozy/src/design/components/ds_category_tree_picker.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/catalog/catalog_repository.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_category.dart';
import 'package:klozy/src/feature/search/presentation/widget/category_products_widget.dart';

/// Hierarchical category browser for Search. Opened by tapping a root category
/// card on the browse screen; starts *inside* [root] and drills down the
/// recursive tree (with breadcrumb). On reaching a leaf it shows that category's
/// products **in place** (matching the design's Category screen) rather than
/// popping a filter back to the search page. Back steps out of the product grid
/// first, then pops the route.
@RoutePage()
class SearchCategoryPage extends StatefulWidget implements AutoRouteWrapper {
  final CatalogCategory root;

  const SearchCategoryPage({super.key, required this.root});

  @override
  Widget wrappedRoute(BuildContext context) => this;

  @override
  State<SearchCategoryPage> createState() => _SearchCategoryPageState();
}

class _SearchCategoryPageState extends State<SearchCategoryPage> {
  PickedCategory? _leaf;

  void _onBack() {
    if (_leaf != null) {
      setState(() => _leaf = null);
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final PickedCategory? leaf = _leaf;
    return Scaffold(
      backgroundColor: DSColor.surface,
      appBar: DSAppBar(
        title: leaf?.path ?? widget.root.label,
        backType: BackType.push,
        overrideBackAction: _onBack,
      ),
      body: SafeArea(
        child: leaf == null
            ? SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: DSCategoryTreePicker(
                  repo: locator<CatalogRepository>(),
                  initialParent: widget.root,
                  showBreadcrumb: true,
                  onLeafSelected: (PickedCategory picked) {
                    setState(() => _leaf = picked);
                  },
                ),
              )
            : CategoryProductsWidget(categoryId: leaf.id),
      ),
    );
  }
}
