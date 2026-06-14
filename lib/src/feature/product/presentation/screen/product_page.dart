import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klozy/src/app/cart/cart_cubit.dart';
import 'package:klozy/src/core/components/app_error_widget.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_bottom_sheet.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/offers/offers_repository.dart';
import 'package:klozy/src/domain/product/entity/product_detail.dart';
import 'package:klozy/src/feature/cart/presentation/widget/offer_sheet.dart';
import 'package:klozy/src/feature/chat/entry/chat_launcher.dart';
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

  /// In-place make-offer: enter an amount, silently ensure the item is in the
  /// cart (offers cover a seller's whole bucket server-side — no navigation to
  /// the cart), submit the offer, then open the chat with the seller where the
  /// offer bubble appears. Mirrors the old app's flow.
  Future<void> _makeOffer(BuildContext context) async {
    final num? amount = await DSBottomSheet.show<num>(
      context,
      title: context.l10N.cart_make_an_offer,
      child: OfferSheet(subtotal: _detail.price, itemCount: 1),
    );
    if (amount == null || !context.mounted) return;
    try {
      if (!state.inCart) {
        await context.read<CartCubit>().add(_detail.id);
      }
      await locator<OffersRepository>().makeOffer(
        sellerId: _detail.seller.id,
        amount: amount,
      );
      if (!context.mounted) return;
      context.read<CartCubit>().refresh();
      await context.openChatWith(_detail.seller.id);
    } on DioException catch (e) {
      // 409 = an active offer with this seller already exists. Don't error —
      // just open the chat where that offer lives.
      if (e.response?.statusCode == 409 && context.mounted) {
        await context.openChatWith(_detail.seller.id);
      } else if (context.mounted) {
        context.showSnackBar(context.l10N.offer_send_failed);
      }
    } catch (_) {
      if (context.mounted) {
        context.showSnackBar(context.l10N.offer_send_failed);
      }
    }
  }

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
                        // Fill the hero so the scrim's FractionallySizedBox has
                        // a bounded height (a bottom-only Positioned leaves it
                        // unbounded → "infinite height" layout error).
                        const Positioned.fill(
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
              onAddToCart: () {
                context.read<ProductBloc>().add(const ProductAddToCart());
                context.read<CartCubit>().refresh();
                context.showSnackBar(context.l10N.product_added_to_cart);
              },
              onViewCart: () => context.router.push(const CartRoute()),
              onEdit: () =>
                  context.router.push(EditListingRoute(productId: detail.id)),
              onDelete: () =>
                  context.read<ProductBloc>().add(const ProductDeleted()),
              onMakeOffer: () => _makeOffer(context),
              onSeeOffer: () => context.openChatWith(detail.seller.id),
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
