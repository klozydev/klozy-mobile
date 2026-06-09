import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klozy/src/app/cart/cart_cubit.dart';
import 'package:klozy/src/app/wishlist/wishlist_cubit.dart';
import 'package:klozy/src/core/components/app_error_widget.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/core/util/app_share.dart';
import 'package:klozy/src/design/components/ds_attribute_chip.dart';
import 'package:klozy/src/design/components/ds_bottom_sheet.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_glass_button.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/product/entity/product_detail.dart';
import 'package:klozy/src/feature/product/presentation/bloc/product_bloc.dart';
import 'package:klozy/src/feature/product/presentation/bloc/product_event.dart';
import 'package:klozy/src/feature/product/presentation/bloc/product_state.dart';
import 'package:klozy/src/feature/product/presentation/widget/product_carousel_widget.dart';
import 'package:klozy/src/feature/product/presentation/widget/product_cta_bar_widget.dart';
import 'package:klozy/src/feature/product/presentation/widget/product_menu_sheet.dart';
import 'package:klozy/src/feature/product/presentation/widget/product_seller_card_widget.dart';
import 'package:klozy/src/router/app_router.dart';

@RoutePage()
class ProductPage extends StatelessWidget implements AutoRouteWrapper {
  final String id;

  const ProductPage({@PathParam('id') required this.id, super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<ProductBloc>(
      create: (_) => locator<ProductBloc>()..add(ProductStarted(id)),
      child: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (BuildContext context, ProductState state) {
        return switch (state) {
          ProductLoadingState() => const Scaffold(
            backgroundColor: DSColor.surface,
            body: DSLoader(),
          ),
          ProductErrorState(:final type) => Scaffold(
            backgroundColor: DSColor.surface,
            appBar: AppBar(),
            body: AppErrorWidget(
              type: type,
              onRetry: () =>
                  context.read<ProductBloc>().add(ProductStarted(id)),
            ),
          ),
          ProductDeletedState() => _DeletedView(),
          ProductLoadedState() => _LoadedView(state: state),
        };
      },
    );
  }
}

class _LoadedView extends StatefulWidget {
  final ProductLoadedState state;

  const _LoadedView({required this.state});

  @override
  State<_LoadedView> createState() => _LoadedViewState();
}

class _LoadedViewState extends State<_LoadedView> {
  final ScrollController _scroll = ScrollController();
  final ValueNotifier<double> _reveal = ValueNotifier<double>(1);

  ProductLoadedState get state => widget.state;
  ProductDetail get _detail => state.detail;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      _reveal.value = (1 - _scroll.offset / 160).clamp(0.0, 1.0);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _reveal.dispose();
    super.dispose();
  }

  Future<void> _openMenu(BuildContext context) {
    final bloc = context.read<ProductBloc>();
    return DSBottomSheet.show<void>(
      context,
      child: ProductMenuSheet(
        isOwner: _detail.isOwner,
        isSold: _detail.status == ProductStatus.sold,
        onEdit: () {
          Navigator.of(context).maybePop();
          context.router.push(EditListingRoute(productId: _detail.id));
        },
        onToggleSold: () {
          Navigator.of(context).maybePop();
          bloc.add(
            ProductMarkStatus(
              _detail.status == ProductStatus.sold
                  ? ProductStatus.active
                  : ProductStatus.sold,
            ),
          );
        },
        onDelete: () {
          Navigator.of(context).maybePop();
          bloc.add(const ProductDeleted());
        },
        onReport: () {
          Navigator.of(context).maybePop();
          bloc.add(const ProductReported());
          context.showSnackBar(context.l10N.product_report_received);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final detail = _detail;
    return Scaffold(
      backgroundColor: DSColor.surface,
      bottomNavigationBar: ProductCtaBarWidget(
        detail: detail,
        inCart: state.inCart,
        onAddToCart: () {
          context.read<ProductBloc>().add(const ProductAddToCart());
          context.read<CartCubit>().refresh();
          context.showSnackBar(context.l10N.product_added_to_cart);
        },
        onViewCart: () => context.router.push(const CartRoute()),
        onEdit: () =>
            context.router.push(EditListingRoute(productId: detail.id)),
        onDelete: () => context.read<ProductBloc>().add(const ProductDeleted()),
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            controller: _scroll,
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    ProductCarouselWidget(
                      images: detail.images,
                      status: detail.status,
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 36,
                      child: ValueListenableBuilder<double>(
                        valueListenable: _reveal,
                        builder:
                            (BuildContext context, double t, Widget? child) {
                              return Opacity(
                                opacity: t,
                                child: Transform.translate(
                                  offset: Offset(0, (1 - t) * 16),
                                  child: child,
                                ),
                              );
                            },
                        child: _titlePrice(context, detail),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ProductSellerCardWidget(
                        seller: detail.seller,
                        isOwner: detail.isOwner,
                        onMessage: () => context.showSnackBar(
                          context.l10N.product_messaging_coming_soon,
                        ),
                        onTap: detail.isOwner
                            ? null
                            : () => context.router.push(
                                UserProfileRoute(userId: detail.seller.id),
                              ),
                      ),
                      const SizedBox(height: 16),
                      _meta(detail),
                      if (detail.description.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 16),
                        Text(
                          detail.description,
                          style: const TextStyle(
                            fontFamily: dsFontFamily,
                            fontSize: DSFontSize.bodyLarge,
                            height: 1.5,
                            color: DSColor.onSurface75,
                          ),
                        ),
                      ],
                      if (detail.isOwner) ...<Widget>[
                        const SizedBox(height: 20),
                        _ownerStats(context, detail),
                      ],
                      if (!detail.isOwner)
                        TextButton(
                          onPressed: () {
                            context.read<ProductBloc>().add(
                              const ProductReported(),
                            );
                            context.showSnackBar(
                              context.l10N.product_report_received,
                            );
                          },
                          child: Text(
                            context.l10N.product_report_this_listing,
                            style: const TextStyle(
                              fontFamily: dsFontFamily,
                              fontSize: DSFontSize.bodyMedium,
                              color: DSColor.onSurface45,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: <Widget>[
                  DSGlassButton(
                    onTap: () => context.router.maybePop(),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  if (!detail.isOwner) _heart(context, detail),
                  const SizedBox(width: 8),
                  DSGlassButton(
                    onTap: () =>
                        AppShare.product(detail.id, title: detail.title),
                    child: const Icon(
                      Icons.ios_share_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  DSGlassButton(
                    onTap: () => _openMenu(context),
                    child: const Icon(
                      Icons.more_horiz,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heart(BuildContext context, ProductDetail detail) {
    final bool liked = context.select<WishlistCubit, bool>(
      (WishlistCubit c) => c.state.contains(detail.id),
    );
    return DSGlassButton(
      onTap: () => context.read<WishlistCubit>().toggle(detail.id),
      child: Icon(
        liked ? Icons.favorite : Icons.favorite_border,
        size: 18,
        color: liked ? DSColor.danger : Colors.white,
      ),
    );
  }

  Widget _titlePrice(BuildContext context, ProductDetail detail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          detail.title,
          style: const TextStyle(
            fontFamily: dsFontFamily,
            fontSize: DSFontSize.headlineLarge,
            fontWeight: DSFontWeight.bold,
            color: Colors.white,
            shadows: <Shadow>[Shadow(color: Color(0x99000000), blurRadius: 6)],
          ),
        ),
        const SizedBox(height: 6),
        Text.rich(
          TextSpan(
            text: context.l10N.product_price_amount(detail.price.toInt()),
            style: const TextStyle(
              fontFamily: dsFontFamily,
              fontSize: DSFontSize.displayLarge,
              fontWeight: DSFontWeight.bold,
              color: DSColor.primary,
            ),
            children: <TextSpan>[
              TextSpan(
                text: context.l10N.product_currency_dhs,
                style: const TextStyle(
                  fontSize: DSFontSize.bodyMedium,
                  fontWeight: DSFontWeight.medium,
                  color: DSColor.onSurface60,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            if (detail.brand.isNotEmpty) DSAttributeChip(label: detail.brand),
            if (detail.size.isNotEmpty) DSAttributeChip(label: detail.size),
            if (detail.conditionLabel != null)
              DSAttributeChip(label: detail.conditionLabel!),
          ],
        ),
      ],
    );
  }

  Widget _meta(ProductDetail detail) {
    final parts = <Widget>[];
    if (detail.postedLabel != null) {
      parts.add(_metaChip(Icons.schedule, detail.postedLabel!));
    }
    if (detail.location != null) {
      parts.add(_metaChip(Icons.location_on_outlined, detail.location!));
    }
    if (parts.isEmpty) return const SizedBox.shrink();
    return Wrap(spacing: 8, runSpacing: 8, children: parts);
  }

  Widget _metaChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 14, color: DSColor.onSurface45),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            fontFamily: dsFontFamily,
            fontSize: DSFontSize.bodyMedium,
            color: DSColor.onSurface60,
          ),
        ),
      ],
    );
  }

  Widget _ownerStats(BuildContext context, ProductDetail detail) {
    final stats = <List<String>>[
      <String>[context.l10N.product_stat_views, '${detail.views}'],
      <String>[context.l10N.product_stat_likes, '${detail.likes}'],
      if (detail.postedLabel != null)
        <String>[context.l10N.product_stat_posted, detail.postedLabel!],
    ];
    return Row(
      children: stats.map((List<String> s) {
        return Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                s[0],
                style: const TextStyle(
                  fontFamily: dsFontFamily,
                  fontSize: DSFontSize.bodySmall,
                  color: DSColor.onSurface35,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                s[1],
                style: const TextStyle(
                  fontFamily: dsFontFamily,
                  fontSize: DSFontSize.bodyMedium,
                  fontWeight: DSFontWeight.semiBold,
                  color: DSColor.onSurface85,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _DeletedView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColor.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.delete_outline_rounded,
                size: 44,
                color: DSColor.onSurface45,
              ),
              const SizedBox(height: 16),
              Text(
                context.l10N.product_listing_deleted,
                style: const TextStyle(
                  fontFamily: dsFontFamily,
                  fontSize: DSFontSize.titleLarge,
                  fontWeight: DSFontWeight.semiBold,
                  color: DSColor.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              DSButtonElevated(
                text: context.l10N.product_back_to_feed,
                onPressed: () => context.router.maybePop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
