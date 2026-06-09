import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/core/pagination/paginated_list.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/product/entity/product.dart';
import 'package:klozy/src/domain/wishlist/wishlist_repository.dart';
import 'package:klozy/src/feature/home/presentation/widget/product_card_widget.dart';

class WishlistTabWidget extends StatefulWidget {
  const WishlistTabWidget({super.key});

  @override
  State<WishlistTabWidget> createState() => _WishlistTabWidgetState();
}

class _WishlistTabWidgetState extends State<WishlistTabWidget> {
  late Future<PaginatedList<Product>> _future;

  @override
  void initState() {
    super.initState();
    _future = locator<WishlistRepository>().getWishlistProducts();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PaginatedList<Product>>(
      future: _future,
      builder:
          (
            BuildContext context,
            AsyncSnapshot<PaginatedList<Product>> snapshot,
          ) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const DSLoader();
            }
            final items = snapshot.data?.data ?? const <Product>[];
            if (items.isEmpty) {
              return const _Empty();
            }
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.56,
              ),
              itemCount: items.length,
              itemBuilder: (BuildContext context, int i) =>
                  ProductCardWidget(product: items[i]),
            );
          },
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.favorite_border_rounded,
            size: 40,
            color: DSColor.onSurface35,
          ),
          const SizedBox(height: 12),
          Text(
            context.l10N.home_wishlist_empty,
            style: const TextStyle(
              fontFamily: dsFontFamily,
              fontSize: DSFontSize.bodyLarge,
              fontWeight: DSFontWeight.medium,
              color: DSColor.onSurface60,
            ),
          ),
        ],
      ),
    );
  }
}
