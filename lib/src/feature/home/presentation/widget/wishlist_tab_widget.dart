import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klozy/src/app/wishlist/wishlist_cubit.dart';
import 'package:klozy/src/core/events/wishlist_changed_event.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/core/pagination/paginated_list.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/product/entity/product.dart';
import 'package:klozy/src/domain/wishlist/wishlist_repository.dart';
import 'package:klozy/src/feature/home/presentation/widget/product_card_widget.dart';

/// Wishlist tab. Refetches every time the tab becomes [active] (so items
/// wished elsewhere appear), and filters the fetched list against the live
/// [WishlistCubit] set (so unwished items disappear instantly).
class WishlistTabWidget extends StatefulWidget {
  final bool active;

  const WishlistTabWidget({super.key, required this.active});

  @override
  State<WishlistTabWidget> createState() => _WishlistTabWidgetState();
}

class _WishlistTabWidgetState extends State<WishlistTabWidget> {
  late Future<PaginatedList<Product>> _future;
  late final StreamSubscription<WishlistChangedEvent> _wishlistChangedSub;

  @override
  void initState() {
    super.initState();
    _future = locator<WishlistRepository>().getWishlistProducts();
    _wishlistChangedSub = locator<EventBus>().on<WishlistChangedEvent>().listen(
      (_) => _reload(),
    );
  }

  @override
  void didUpdateWidget(WishlistTabWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _reload();
    }
  }

  void _reload() {
    setState(() {
      _future = locator<WishlistRepository>().getWishlistProducts();
    });
  }

  @override
  void dispose() {
    _wishlistChangedSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Set<String> wishedIds = context.watch<WishlistCubit>().state;
    return RefreshIndicator(
      color: DSColor.primary,
      backgroundColor: DSColor.card,
      onRefresh: () async => _reload(),
      child: FutureBuilder<PaginatedList<Product>>(
        future: _future,
        builder:
            (
              BuildContext context,
              AsyncSnapshot<PaginatedList<Product>> snapshot,
            ) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const DSLoader();
              }
              final items = (snapshot.data?.data ?? const <Product>[])
                  .where((Product p) => wishedIds.contains(p.id))
                  .toList();
              if (items.isEmpty) {
                // Wrap in a scrollable so RefreshIndicator can be triggered even
                // when the list is empty.
                return LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) =>
                      SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: constraints.maxHeight,
                          child: const _Empty(),
                        ),
                      ),
                );
              }
              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: <Widget>[
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      DSSpacing.s,
                      DSSpacing.s,
                      DSSpacing.s,
                      DSSpacing.xs,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        context.l10N.home_wishlist_saved_count(items.length),
                        style: const TextStyle(
                          fontFamily: dsFontFamily,
                          fontSize: DSFontSize.bodyMedium,
                          color: DSColor.onSurface45,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      DSSpacing.s,
                      0,
                      DSSpacing.s,
                      DSSpacing.l,
                    ),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 0.56,
                          ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int i) =>
                            ProductCardWidget(product: items[i]),
                        childCount: items.length,
                      ),
                    ),
                  ),
                ],
              );
            },
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: DSSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: DSColor.onSurface05,
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                size: 28,
                color: DSColor.onSurface60,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10N.home_wishlist_empty,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: dsFontFamily,
                fontSize: DSFontSize.titleLarge,
                fontWeight: DSFontWeight.semiBold,
                color: DSColor.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              context.l10N.home_wishlist_empty_hint,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: dsFontFamily,
                fontSize: DSFontSize.bodyMedium,
                height: 1.4,
                color: DSColor.onSurface45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
