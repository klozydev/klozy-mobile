import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klozy/src/app/wishlist/wishlist_cubit.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/core/components/app_error_widget.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/product/entity/product.dart';
import 'package:klozy/src/feature/home/presentation/bloc/wishlist_feed_cubit.dart';
import 'package:klozy/src/feature/home/presentation/bloc/wishlist_feed_state.dart';
import 'package:klozy/src/feature/home/presentation/widget/product_card_widget.dart';

/// Bottom-of-list loading affordance shown while a "load more" fetch is in
/// flight. Mirrors the Feed/Profile tabs' inline sliver spinner.
const Widget _kWishlistLoadMoreSliver = SliverToBoxAdapter(
  child: Padding(
    padding: EdgeInsets.symmetric(vertical: DSSpacing.s),
    child: DSLoader(size: 22),
  ),
);

/// Wishlist tab. Owns a per-instance [WishlistFeedCubit], refetches every
/// time the tab becomes [active] (so items wished elsewhere appear), and
/// filters the fetched list against the live [WishlistCubit] set (so unwished
/// items disappear instantly).
class WishlistTabWidget extends StatefulWidget {
  final bool active;

  const WishlistTabWidget({super.key, required this.active});

  @override
  State<WishlistTabWidget> createState() => _WishlistTabWidgetState();
}

class _WishlistTabWidgetState extends State<WishlistTabWidget> {
  late final WishlistFeedCubit _cubit;
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _cubit = locator<WishlistFeedCubit>()..load();
    _controller.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(WishlistTabWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _cubit.refresh();
    }
  }

  void _onScroll() {
    final WishlistFeedState state = _cubit.state;
    if (state is! WishlistFeedLoaded || state.loadingMore || !state.hasMore) {
      return;
    }
    if (_controller.position.pixels >=
        _controller.position.maxScrollExtent - 300) {
      _cubit.loadMore();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<WishlistFeedCubit>.value(
      value: _cubit,
      child: RefreshIndicator(
        color: DSColor.primary,
        backgroundColor: DSColor.card,
        onRefresh: _cubit.refresh,
        child: BlocBuilder<WishlistFeedCubit, WishlistFeedState>(
          bloc: _cubit,
          builder: (BuildContext context, WishlistFeedState state) {
            return switch (state) {
              WishlistFeedLoading() => const DSLoader(),
              WishlistFeedError(:final type) => _WishlistErrorView(
                controller: _controller,
                type: type,
                onRetry: _cubit.load,
              ),
              WishlistFeedLoaded(:final items, :final loadingMore) =>
                _WishlistLoadedBody(
                  controller: _controller,
                  items: items,
                  loadingMore: loadingMore,
                ),
            };
          },
        ),
      ),
    );
  }
}

/// Error state for the Wishlist tab, wrapped in a scrollable so
/// pull-to-refresh still works when the fetch failed.
class _WishlistErrorView extends StatelessWidget {
  final ScrollController controller;
  final AppErrorType type;
  final VoidCallback onRetry;

  const _WishlistErrorView({
    required this.controller,
    required this.type,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: controller,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: <Widget>[
        SliverFillRemaining(
          hasScrollBody: false,
          child: AppErrorWidget(type: type, onRetry: onRetry),
        ),
      ],
    );
  }
}

/// Loaded state for the Wishlist tab: filters [items] against the live
/// [WishlistCubit] id-set, then renders the saved-count header and grid (or
/// the empty state), plus a bottom loader while [loadingMore].
class _WishlistLoadedBody extends StatelessWidget {
  final ScrollController controller;
  final List<Product> items;
  final bool loadingMore;

  const _WishlistLoadedBody({
    required this.controller,
    required this.items,
    required this.loadingMore,
  });

  @override
  Widget build(BuildContext context) {
    final Set<String> wishedIds = context.watch<WishlistCubit>().state;
    final List<Product> filtered = items
        .where((Product p) => wishedIds.contains(p.id))
        .toList();
    return CustomScrollView(
      controller: controller,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: <Widget>[
        if (filtered.isEmpty)
          const SliverFillRemaining(hasScrollBody: false, child: _Empty())
        else ...<Widget>[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              DSSpacing.s,
              DSSpacing.s,
              DSSpacing.s,
              DSSpacing.xs,
            ),
            sliver: SliverToBoxAdapter(
              child: Text(
                context.l10N.home_wishlist_saved_count(filtered.length),
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
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.56,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int i) =>
                    ProductCardWidget(product: filtered[i]),
                childCount: filtered.length,
              ),
            ),
          ),
          if (loadingMore) _kWishlistLoadMoreSliver,
        ],
      ],
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
