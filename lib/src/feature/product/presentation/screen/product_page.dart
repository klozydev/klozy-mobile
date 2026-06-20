import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klozy/src/core/account/account_gate.dart';
import 'package:klozy/src/core/components/app_error_widget.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_bottom_sheet.dart';
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
import 'package:klozy/src/feature/product/presentation/widget/product_menu_sheet.dart';
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
  final ScrollController _scroll = ScrollController();
  int _currentPage = 0;
  double _offset = 0;

  // Two-state immersive scroll (design reference product_detail_screen.dart):
  // the photo is fullscreen in `minimized`; pulling up reveals the details and
  // the screen snaps to the nearest state on release.
  // Title→bottom gap while minimized (clears the floating CTAs).
  static const double _kTitlePinned = 88;
  // Final gap between the chips and the seller card once expanded.
  static const double _kTitleTight = 14;
  // Past this fraction of the scroll extent we snap to `expanded`.
  static const double _kSnapThreshold = 0.22;

  ProductLoadedState get state => widget.state;
  ProductDetail get _detail => state.detail;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (mounted) setState(() => _offset = _scroll.offset);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) => setState(() => _currentPage = page);

  /// On gesture end, animate to whichever state is closest — fully collapsed
  /// (photo) or fully expanded (details).
  bool _onScrollEnd(ScrollEndNotification _) {
    if (!_scroll.hasClients) return false;
    final double max = _scroll.position.maxScrollExtent;
    if (max <= 0) return false;
    final double target = _offset > max * _kSnapThreshold ? max : 0.0;
    if ((_scroll.offset - target).abs() > 0.5) {
      _scroll.animateTo(
        target,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
    return false;
  }

  /// Owner overflow menu (opened from the trash button on the CTA bar):
  /// Edit / Mark sold-available / Delete. Matches the design, where mark-sold
  /// and delete live in this menu rather than as primary buttons.
  Future<void> _openOwnerMenu(BuildContext context) {
    final ProductBloc bloc = context.read<ProductBloc>();
    return DSBottomSheet.show<void>(
      context,
      child: ProductMenuSheet(
        isOwner: true,
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
          _confirmDelete(context);
        },
        onReport: () {},
      ),
    );
  }

  /// Confirm before deleting the user's own listing — deletion is irreversible.
  Future<void> _confirmDelete(BuildContext context) async {
    final bloc = context.read<ProductBloc>();
    final bool ok =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext c) => AlertDialog(
            backgroundColor: DSColor.card,
            content: Text(
              context.l10N.product_delete_confirm,
              style: const TextStyle(color: DSColor.onSurface),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(c).pop(false),
                child: Text(context.l10N.settings_cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(c).pop(true),
                child: Text(
                  context.l10N.product_delete_listing,
                  style: const TextStyle(color: DSColor.danger),
                ),
              ),
            ],
          ),
        ) ??
        false;
    if (ok) bloc.add(const ProductDeleted());
  }

  /// Inline "Report this listing" — fires the report and confirms via snackbar
  /// (same flow as the overflow menu's report action).
  void _report(BuildContext context) {
    context.read<ProductBloc>().add(const ProductReported());
    context.showSnackBar(context.l10N.product_report_received);
  }

  @override
  Widget build(BuildContext context) {
    final ProductDetail detail = _detail;
    final int imageCount = detail.images.length;
    final double screenHeight = MediaQuery.sizeOf(context).height;
    // The title block is anchored [titleBottom] above the hero's bottom edge.
    // It stays pinned at the start of the scroll (88) then hugs the seller card
    // (14) as the screen expands.
    final double titleBottom = (_kTitlePinned - _offset)
        .clamp(_kTitleTight, _kTitlePinned)
        .toDouble();

    return Scaffold(
      backgroundColor: DSColor.surface,
      body: Stack(
        children: <Widget>[
          // Immersive two-state scroll: the hero photo fills the screen; pulling
          // up reveals the details panel and the page snaps to the nearest state
          // on release. The title block is pinned over the hero, then sticks to
          // the seller card.
          NotificationListener<ScrollEndNotification>(
            onNotification: _onScrollEnd,
            child: SingleChildScrollView(
              controller: _scroll,
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        const Positioned.fill(
                          child: IgnorePointer(
                            child: ProductBottomScrimWidget(),
                          ),
                        ),
                        const Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: ProductTopScrimWidget(),
                        ),
                        if (imageCount > 1)
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 44),
                                child: ProductPageDotsWidget(
                                  count: imageCount,
                                  current: _currentPage,
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: titleBottom,
                          child: ProductTitleBlockWidget(product: detail),
                        ),
                      ],
                    ),
                  ),
                  ProductDetailsPanelWidget(
                    detail: detail,
                    isOwner: detail.isOwner,
                    onReport: () => _report(context),
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
                // ProductBloc reloads the CartCubit once the add persists, so
                // the badge updates without racing a premature refresh here.
                context.read<ProductBloc>().add(const ProductAddToCart());
                context.showSnackBar(context.l10N.product_added_to_cart);
              },
              onViewCart: () => locator<AccountGate>().guard(
                context,
                onAllowed: () => context.router.push(const CartRoute()),
              ),
              onEdit: () =>
                  context.router.push(EditListingRoute(productId: detail.id)),
              onOpenMenu: () => _openOwnerMenu(context),
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
              const SizedBox(height: DSSpacing.xs),
              Text(
                context.l10N.product_listing_deleted_subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: dsFontFamily,
                  fontSize: DSFontSize.bodyMedium,
                  color: DSColor.onSurface45,
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
