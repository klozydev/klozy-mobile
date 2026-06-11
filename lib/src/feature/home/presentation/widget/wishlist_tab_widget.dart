import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klozy/src/app/wishlist/wishlist_cubit.dart';
import 'package:klozy/src/core/events/wishlist_changed_event.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/product/entity/product.dart';
import 'package:klozy/src/domain/wishlist/wishlist_repository.dart';
import 'package:klozy/src/feature/home/presentation/widget/product_card_widget.dart';

/// Wishlist tab. Refetches every time the tab becomes [active] (so items
/// wished elsewhere appear), paginates on scroll, and filters the fetched
/// list against the live [WishlistCubit] set (so unwished items disappear
/// instantly).
class WishlistTabWidget extends StatefulWidget {
  final bool active;

  const WishlistTabWidget({super.key, required this.active});

  @override
  State<WishlistTabWidget> createState() => _WishlistTabWidgetState();
}

class _WishlistTabWidgetState extends State<WishlistTabWidget> {
  static const int _limit = 20;

  final ScrollController _scrollController = ScrollController();
  late final StreamSubscription<WishlistChangedEvent> _wishlistChangedSub;

  List<Product> _items = const <Product>[];
  int _page = 1;
  bool _hasMore = true;
  bool _loading = true;
  bool _loadingMore = false;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _reload();
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

  @override
  void dispose() {
    _wishlistChangedSub.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 400) {
      _loadMore();
    }
  }

  Future<void> _reload() async {
    final requestId = ++_requestId;
    setState(() => _loading = _items.isEmpty);
    try {
      final page = await locator<WishlistRepository>().getWishlistProducts(
        limit: _limit,
      );
      if (!mounted || requestId != _requestId) return;
      // Seed the global set with the server-confirmed ids — if the cubit's
      // startup load failed, filtering against an empty set would render a
      // false "wishlist empty" despite server data.
      context.read<WishlistCubit>().seed(
        page.data.map((Product p) => p.id).where((String s) => s.isNotEmpty),
      );
      setState(() {
        _items = page.data;
        _page = 1;
        _hasMore = page.data.length >= _limit;
        _loading = false;
      });
    } catch (_) {
      if (!mounted || requestId != _requestId) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_loading || _loadingMore || !_hasMore) return;
    final requestId = _requestId;
    setState(() => _loadingMore = true);
    try {
      final page = await locator<WishlistRepository>().getWishlistProducts(
        page: _page + 1,
        limit: _limit,
      );
      if (!mounted || requestId != _requestId) return;
      context.read<WishlistCubit>().seed(
        page.data.map((Product p) => p.id).where((String s) => s.isNotEmpty),
      );
      setState(() {
        _items = <Product>[..._items, ...page.data];
        _page += 1;
        _hasMore = page.data.length >= _limit;
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted || requestId != _requestId) return;
      setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Set<String> wishedIds = context.watch<WishlistCubit>().state;
    final List<Product> items = _items
        .where((Product p) => wishedIds.contains(p.id))
        .toList();
    return RefreshIndicator(
      color: DSColor.primary,
      backgroundColor: DSColor.card,
      onRefresh: _reload,
      child: _loading
          ? const DSLoader()
          : items.isEmpty
          // Wrap in a scrollable so RefreshIndicator can be triggered even
          // when the list is empty.
          ? LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) =>
                  SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: constraints.maxHeight,
                      child: const _Empty(),
                    ),
                  ),
            )
          : GridView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
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
            ),
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
