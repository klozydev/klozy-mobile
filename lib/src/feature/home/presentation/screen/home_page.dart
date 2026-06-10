import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klozy/src/app/cart/cart_cubit.dart';
import 'package:klozy/src/app/notifications/notifications_cubit.dart';
import 'package:klozy/src/app/push/push_service.dart';
import 'package:klozy/src/app/wishlist/wishlist_cubit.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_bottom_sheet.dart';
import 'package:klozy/src/design/components/ds_cart_badge.dart';
import 'package:klozy/src/design/components/ds_klozy_mark.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/cart/entity/cart.dart';
import 'package:klozy/src/domain/config/public_config_repository.dart';
import 'package:klozy/src/feature/home/presentation/bloc/feed_bloc.dart';
import 'package:klozy/src/feature/home/presentation/bloc/feed_event.dart';
import 'package:klozy/src/feature/home/presentation/widget/feed_tab_widget.dart';
import 'package:klozy/src/feature/home/presentation/widget/legal_acceptance_sheet.dart';
import 'package:klozy/src/feature/home/presentation/widget/notifications_bell_widget.dart';
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

  @override
  void initState() {
    super.initState();
    context.read<WishlistCubit>().load();
    context.read<CartCubit>().load();
    context.read<NotificationsCubit>().load();
    locator<PushService>().init().ignore();
    _checkPendingLegal();
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
    return Scaffold(
      backgroundColor: DSColor.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 14, 4),
              child: Row(
                children: <Widget>[
                  const DSKlozyMark(size: 22),
                  const Spacer(),
                  BlocBuilder<NotificationsCubit, int>(
                    builder: (BuildContext context, int unread) =>
                        NotificationsBellWidget(
                          count: unread,
                          onTap: () =>
                              context.router.push(const NotificationsRoute()),
                        ),
                  ),
                  const SizedBox(width: 4),
                  BlocBuilder<CartCubit, Cart>(
                    builder: (BuildContext context, Cart cart) => DSCartBadge(
                      count: cart.itemCount,
                      onTap: () => context.router.push(const CartRoute()),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ShellTabsWidget(
                  tabs: <String>[
                    context.l10N.home_tab_feed,
                    context.l10N.home_tab_wishlist,
                    context.l10N.home_tab_reels,
                  ],
                  selectedIndex: _tab,
                  onChanged: (int i) => setState(() => _tab = i),
                ),
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _tab,
                children: <Widget>[
                  const FeedTabWidget(),
                  WishlistTabWidget(active: _tab == 1),
                  ReelViewerWidget(active: _tab == 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
