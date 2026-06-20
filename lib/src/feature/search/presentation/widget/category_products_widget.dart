import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/product/entity/feed_page.dart';
import 'package:klozy/src/domain/product/entity/product.dart';
import 'package:klozy/src/domain/product/products_repository.dart';
import 'package:klozy/src/feature/home/presentation/widget/product_card_widget.dart';

/// In-place product grid for a chosen category (the design's Category screen).
/// Loads the first page of that category's listings and shows a `{n} items`
/// header above the grid.
class CategoryProductsWidget extends StatefulWidget {
  final String categoryId;

  const CategoryProductsWidget({super.key, required this.categoryId});

  @override
  State<CategoryProductsWidget> createState() => _CategoryProductsWidgetState();
}

class _CategoryProductsWidgetState extends State<CategoryProductsWidget> {
  static const SliverGridDelegateWithFixedCrossAxisCount _gridDelegate =
      SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.56,
      );

  late Future<FeedPage> _future;

  @override
  void initState() {
    super.initState();
    _future = locator<ProductsRepository>().feed(
      categoryId: widget.categoryId,
      limit: 30,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FeedPage>(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<FeedPage> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const DSLoader();
        }
        final List<Product> items = snapshot.data?.data ?? const <Product>[];
        if (items.isEmpty) {
          return Center(
            child: Text(
              context.l10N.category_empty,
              style: const TextStyle(
                fontFamily: dsFontFamily,
                fontSize: DSFontSize.bodyLarge,
                color: DSColor.onSurface45,
              ),
            ),
          );
        }
        return CustomScrollView(
          slivers: <Widget>[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              sliver: SliverToBoxAdapter(
                child: Text(
                  context.l10N.category_items_count(items.length),
                  style: const TextStyle(
                    fontFamily: dsFontFamily,
                    fontSize: DSFontSize.bodyMedium,
                    color: DSColor.onSurface45,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              sliver: SliverGrid.builder(
                gridDelegate: _gridDelegate,
                itemCount: items.length,
                itemBuilder: (BuildContext context, int i) =>
                    ProductCardWidget(product: items[i]),
              ),
            ),
          ],
        );
      },
    );
  }
}
