import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klozy/src/app/cart/cart_cubit.dart';
import 'package:klozy/src/core/components/app_error_widget.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/product/entity/product_detail.dart';
import 'package:klozy/src/feature/product/presentation/bloc/product_bloc.dart';
import 'package:klozy/src/feature/product/presentation/bloc/product_event.dart';
import 'package:klozy/src/feature/product/presentation/bloc/product_state.dart';
import 'package:klozy/src/feature/product/presentation/widget/product_bottom_scrim_widget.dart';
import 'package:klozy/src/feature/product/presentation/widget/product_carousel_widget.dart';
import 'package:klozy/src/feature/product/presentation/widget/product_cta_bar_widget.dart';
import 'package:klozy/src/feature/product/presentation/widget/product_details_panel_widget.dart';
import 'package:klozy/src/feature/product/presentation/widget/product_page_dots_widget.dart';
import 'package:klozy/src/feature/product/presentation/widget/product_title_block_widget.dart';
import 'package:klozy/src/feature/product/presentation/widget/product_top_bar_widget.dart';
import 'package:klozy/src/feature/product/presentation/widget/product_top_scrim_widget.dart';
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
    return BlocConsumer<ProductBloc, ProductState>(
      listenWhen: _listenWhen,
      listener: _listener,
      buildWhen: _buildWhen,
      builder: _builder,
    );
  }

  bool _listenWhen(ProductState previous, ProductState current) =>
      current is ProductCartResultState || current is ProductDeleteFailedState;

  void _listener(BuildContext context, ProductState state) {
    if (state is ProductCartResultState) {
      if (state.success) {
        // Refresh the badge only once the POST succeeded — refreshing
        // beforehand raced the add and fetched the stale count.
        context.read<CartCubit>().refresh();
        context.showSnackBar(context.l10N.product_added_to_cart);
      } else {
        context.showSnackBar(context.l10N.error_scenario_generic_title);
      }
    } else if (state is ProductDeleteFailedState) {
      context.showSnackBar(context.l10N.error_scenario_generic_title);
    }
  }

  bool _buildWhen(ProductState previous, ProductState current) =>
      current is! ProductCartResultState &&
      current is! ProductDeleteFailedState;

  Widget _builder(BuildContext context, ProductState state) {
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
          onRetry: () => context.read<ProductBloc>().add(ProductStarted(id)),
        ),
      ),
      ProductDeletedState() => _DeletedView(),
      ProductLoadedState() => _LoadedView(state: state),
      // Transient one-shot states are filtered by _buildWhen; these cases
      // only keep the switch exhaustive.
      ProductCartResultState() ||
      ProductDeleteFailedState() => const SizedBox.shrink(),
    };
  }
}

class _LoadedView extends StatefulWidget {
  final ProductLoadedState state;

  const _LoadedView({required this.state});

  @override
  State<_LoadedView> createState() => _LoadedViewState();
}

class _LoadedViewState extends State<_LoadedView> {
  late final ScrollController _scrollController = ScrollController();
  int _currentPage = 0;

  ProductLoadedState get state => widget.state;
  ProductDetail get _detail => state.detail;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _handleScrollEnd(ScrollEndNotification notification) {
    final double maxExtent = _scrollController.position.maxScrollExtent;
    if (maxExtent <= 0) return false;
    final double current = _scrollController.offset;
    final double threshold = maxExtent * 0.22;
    final double target = current < threshold ? 0.0 : maxExtent;
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
    return true;
  }

  void _onPageChanged(int page) => setState(() => _currentPage = page);

  @override
  Widget build(BuildContext context) {
    final ProductDetail detail = _detail;
    final int imageCount = detail.images.length;
    final double screenHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: DSColor.surface,
      body: Stack(
        children: <Widget>[
          NotificationListener<ScrollEndNotification>(
            onNotification: _handleScrollEnd,
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: screenHeight,
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        ProductCarouselWidget(
                          images: detail.images,
                          status: detail.status,
                          onPageChanged: _onPageChanged,
                        ),
                        const Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: ProductTopScrimWidget(),
                        ),
                        const Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: ProductBottomScrimWidget(),
                        ),
                        Positioned(
                          bottom: DSSpacing.l,
                          left: 0,
                          right: 0,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              if (imageCount > 1) ...<Widget>[
                                ProductPageDotsWidget(
                                  count: imageCount,
                                  current: _currentPage,
                                ),
                                const SizedBox(height: DSSpacing.s),
                              ],
                              ProductTitleBlockWidget(product: detail),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  ProductDetailsPanelWidget(
                    detail: detail,
                    isOwner: detail.isOwner,
                  ),
                ],
              ),
            ),
          ),
          ProductTopBarWidget(detail: detail),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ProductCtaBarWidget(
              detail: detail,
              inCart: state.inCart,
              onAddToCart: () =>
                  context.read<ProductBloc>().add(const ProductAddToCart()),
              onViewCart: () => context.router.push(const CartRoute()),
              onEdit: () =>
                  context.router.push(EditListingRoute(productId: detail.id)),
              onDelete: () =>
                  context.read<ProductBloc>().add(const ProductDeleted()),
              onMakeOffer: () => context.router.push(const OffersRoute()),
            ),
          ),
        ],
      ),
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
          padding: const EdgeInsets.all(DSSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.delete_outline_rounded,
                size: 44,
                color: DSColor.onSurface45,
              ),
              const SizedBox(height: DSSpacing.s),
              Text(
                context.l10N.product_listing_deleted,
                style: const TextStyle(
                  fontFamily: dsFontFamily,
                  fontSize: DSFontSize.titleLarge,
                  fontWeight: DSFontWeight.semiBold,
                  color: DSColor.onSurface,
                ),
              ),
              const SizedBox(height: DSSpacing.m),
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
