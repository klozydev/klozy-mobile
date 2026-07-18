import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klozy/src/core/components/app_error_widget.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/core/navigation/safe_navigation.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/components/ds_segmented_control.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/orders/entity/order_action.dart';
import 'package:klozy/src/domain/orders/entity/order_list_item.dart';
import 'package:klozy/src/feature/orders/presentation/bloc/orders_bloc.dart';
import 'package:klozy/src/feature/orders/presentation/bloc/orders_event.dart';
import 'package:klozy/src/feature/orders/presentation/bloc/orders_state.dart';
import 'package:klozy/src/feature/orders/presentation/widget/order_list_card_widget.dart';
import 'package:klozy/src/router/app_router.dart';

@RoutePage()
class OrdersPage extends StatelessWidget implements AutoRouteWrapper {
  const OrdersPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<OrdersBloc>(
      create: (_) => locator<OrdersBloc>()..add(const OrdersStarted()),
      child: this,
    );
  }

  OrderRole _roleOf(OrdersState state) => switch (state) {
    OrdersLoadingState(:final role) => role,
    OrdersErrorState(:final role) => role,
    OrdersLoadedState(:final role) => role,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColor.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 22),
          onPressed: () => context.router.maybePop(),
        ),
        title: Text(context.l10N.orders_my_orders),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.local_offer_outlined, size: 22),
            tooltip: context.l10N.offers_title,
            onPressed: () => context.router.pushSafe(const OffersRoute()),
          ),
        ],
      ),
      body: BlocBuilder<OrdersBloc, OrdersState>(
        builder: (BuildContext context, OrdersState state) {
          final role = _roleOf(state);
          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: DSSegmentedControl(
                  labels: <String>[
                    context.l10N.orders_buying,
                    context.l10N.orders_selling,
                  ],
                  selectedIndex: role == OrderRole.seller ? 1 : 0,
                  onChanged: (int i) => context.read<OrdersBloc>().add(
                    OrdersRoleChanged(
                      i == 1 ? OrderRole.seller : OrderRole.buyer,
                    ),
                  ),
                ),
              ),
              Expanded(child: _body(context, state, role)),
            ],
          );
        },
      ),
    );
  }

  Widget _body(BuildContext context, OrdersState state, OrderRole role) {
    return switch (state) {
      OrdersLoadingState() => const DSLoader(),
      OrdersErrorState(:final type) => AppErrorWidget(
        type: type,
        onRetry: () => context.read<OrdersBloc>().add(OrdersRoleChanged(role)),
      ),
      OrdersLoadedState() =>
        state.isEmpty
            ? const _Empty()
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: <Widget>[
                  if (state.inProgress.isNotEmpty)
                    ..._section(
                      context.l10N.orders_in_progress,
                      state.inProgress,
                      role,
                      context,
                    ),
                  if (state.completed.isNotEmpty)
                    ..._section(
                      context.l10N.orders_completed,
                      state.completed,
                      role,
                      context,
                    ),
                ],
              ),
    };
  }

  List<Widget> _section(
    String title,
    List<OrderListItem> orders,
    OrderRole role,
    BuildContext context,
  ) {
    return <Widget>[
      Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 10),
        child: Text(
          title,
          style: const TextStyle(
            fontFamily: dsFontFamily,
            fontSize: DSFontSize.titleLarge,
            fontWeight: DSFontWeight.semiBold,
            color: DSColor.onSurface,
          ),
        ),
      ),
      ...orders.map(
        (OrderListItem o) => OrderListCardWidget(
          order: o,
          counterpartPrefix: role == OrderRole.seller
              ? context.l10N.orders_prefix_to
              : context.l10N.orders_prefix_from,
          onTap: () => context.router.pushSafe(OrderDetailRoute(id: o.id)),
        ),
      ),
    ];
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
            Icons.receipt_long_outlined,
            size: 40,
            color: DSColor.onSurface35,
          ),
          const SizedBox(height: 12),
          Text(
            context.l10N.orders_no_orders_yet,
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
