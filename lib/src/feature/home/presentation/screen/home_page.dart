import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klozy/src/app/cart/cart_cubit.dart';
import 'package:klozy/src/app/notifications/notifications_cubit.dart';
import 'package:klozy/src/app/push/push_service.dart';
import 'package:klozy/src/app/wishlist/wishlist_cubit.dart';
import 'package:klozy/src/core/account/account_gate.dart';
import 'package:klozy/src/core/events/open_reels_tab_event.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_bottom_sheet.dart';
import 'package:klozy/src/design/components/ds_cart_badge.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/cart/entity/cart.dart';
import 'package:klozy/src/domain/config/public_config_repository.dart';
import 'package:klozy/src/feature/home/presentation/bloc/feed_bloc.dart';
import 'package:klozy/src/feature/home/presentation/bloc/feed_event.dart';
import 'package:klozy/src/feature/home/presentation/widget/feed_tab_widget.dart';
import 'package:klozy/src/feature/home/presentation/widget/legal_acceptance_sheet.dart';
import 'package:klozy/src/feature/home/presentation/widget/reels_cart_button_widget.dart';
import 'package:klozy/src/feature/home/presentation/widget/shell_tabs_widget.dart';
import 'package:klozy/src/feature/home/presentation/widget/wishlist_tab_widget.dart';
import 'package:klozy/src/feature/reels/presentation/widget/reel_viewer_widget.dart';
import 'package:klozy/src/router/app_router.dart';

@RoutePage()
class HomePage extends StatefulWidget implements AutoRouteWrapper {
  const HomePage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<FeedBloc>(
      create: (_) => locator<FeedBloc>()..add(const FeedStarted()),
      child: this,
    );
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tab = 0;
  late final StreamSubscription<OpenReelsTabEvent> _openReelsSub;

  // The shell's tabs router — used to know whether the Home tab is the one
  // currently on screen. Without it, switching to another shell tab (e.g.
  // Profile) leaves the Reels video (and its audio) playing in the background,
  // so opening a second reel elsewhere plays two audio tracks at once.
  TabsRouter? _tabsRouter;

  bool get _homeTabActive =>
      _tabsRouter == null || _tabsRouter!.activeIndex == 0;

  @override
  void initState() {
    super.initState();
    context.read<WishlistCubit>().load();
    context.read<CartCubit>().load();
    context.read<NotificationsCubit>().load();
    locator<PushService>().init().ignore();
    _checkPendingLegal();
    // Jump to the Reels tab when another flow asks for it (e.g. after posting
    // a reel from the composer).
    _openReelsSub = locator<EventBus>().on<OpenReelsTabEvent>().listen((_) {
      if (mounted) setState(() => _tab = 2);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final TabsRouter router = AutoTabsRouter.of(context);
    if (!identical(router, _tabsRouter)) {
      _tabsRouter?.removeListener(_onShellTabChanged);
      _tabsRouter = router..addListener(_onShellTabChanged);
    }
  }

  // Rebuild so the Reels viewer's `active` flag follows the shell tab and
  // pauses/resumes playback as the user moves between tabs.
  void _onShellTabChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _tabsRouter?.removeListener(_onShellTabChanged);
    _openReelsSub.cancel();
    super.dispose();
  }

  /// Cart requires a complete profile — gate the navigation so guests / users
  /// with incomplete onboarding get the sign-up / finish-setup sheet instead.
  void _openCart(BuildContext context) {
    locator<AccountGate>().guard(
      context,
      onAllowed: () => context.router.push(const CartRoute()),
    );
  }

  Future<void> _checkPendingLegal() async {
    try {
      final docs = await locator<PublicConfigRepository>().getPendingLegal();
      if (docs.isEmpty || !mounted) return;
      await DSBottomSheet.show<void>(
        context,
        title: context.l10N.legal_pending_title,
        child: LegalAcceptanceSheet(docs: docs),
      );
    } catch (_) {
      // Best-effort — never block the home screen on this.
    }
  }

  @override
  Widget build(BuildContext context) {
    final double topInset = MediaQuery.viewPaddingOf(context).top;
    const double barHeight = 52;
    final bool reels = _tab == 2;
    final double contentInset = topInset + barHeight;

    return Scaffold(
      backgroundColor: DSColor.surface,
      body: Stack(
        children: <Widget>[
          // Reels is full-bleed (video runs edge-to-edge under the overlay bar);
          // Feed / Wishlist are inset below the opaque bar.
          Positioned.fill(
            child: IndexedStack(
              index: _tab,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: contentInset),
                  child: const FeedTabWidget(),
                ),
                Padding(
                  padding: EdgeInsets.only(top: contentInset),
                  child: WishlistTabWidget(active: _tab == 1),
                ),
                ReelViewerWidget(active: _tab == 2 && _homeTabActive),
              ],
            ),
          ),
          // One consistent centered Feed / Wishlist / Reels bar across all three
          // tabs (no logo / search row — search lives in the bottom nav). Over
          // Reels it goes transparent so the video shows through; the cart
          // adopts a translucent overlay style.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: reels ? Colors.transparent : DSColor.surface,
              padding: EdgeInsets.only(top: topInset),
              child: SizedBox(
                height: barHeight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 14, 0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      ShellTabsWidget(
                        tabs: <String>[
                          context.l10N.home_tab_feed,
                          context.l10N.home_tab_wishlist,
                          context.l10N.home_tab_reels,
                        ],
                        selectedIndex: _tab,
                        onChanged: (int i) => setState(() => _tab = i),
                        overlay: reels,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: BlocBuilder<CartCubit, Cart>(
                          builder: (BuildContext context, Cart cart) => reels
                              ? ReelsCartButtonWidget(
                                  count: cart.itemCount,
                                  onTap: () => _openCart(context),
                                )
                              : DSCartBadge(
                                  count: cart.itemCount,
                                  onTap: () => _openCart(context),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
