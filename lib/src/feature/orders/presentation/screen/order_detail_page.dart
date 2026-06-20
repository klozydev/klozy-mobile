import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klozy/src/core/components/app_error_widget.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_bottom_sheet.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/cart/entity/cart_item.dart';
import 'package:klozy/src/domain/orders/entity/order_action.dart';
import 'package:klozy/src/feature/chat/entry/chat_launcher.dart';
import 'package:klozy/src/feature/orders/presentation/bloc/order_detail_bloc.dart';
import 'package:klozy/src/feature/orders/presentation/bloc/order_detail_event.dart';
import 'package:klozy/src/feature/orders/presentation/bloc/order_detail_state.dart';
import 'package:klozy/src/feature/orders/presentation/widget/emx_tracking_template.dart';
import 'package:klozy/src/feature/orders/presentation/widget/order_action_bar_widget.dart';
import 'package:klozy/src/feature/orders/presentation/widget/order_counterpart_card_widget.dart';
import 'package:klozy/src/feature/orders/presentation/widget/order_status_pill_widget.dart';
import 'package:klozy/src/feature/orders/presentation/widget/order_tracking_stepper_widget.dart';
import 'package:klozy/src/feature/orders/presentation/widget/report_problem_sheet.dart';
import 'package:klozy/src/feature/orders/presentation/widget/review_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class OrderDetailPage extends StatelessWidget implements AutoRouteWrapper {
  final String id;

  const OrderDetailPage({@PathParam('id') required this.id, super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<OrderDetailBloc>(
      create: (_) => locator<OrderDetailBloc>()..add(OrderDetailStarted(id)),
      child: this,
    );
  }

  Future<void> _open(BuildContext context, String? url) async {
    if (url == null) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        context.showSnackBar(context.l10N.orders_couldnt_open_link);
      }
    }
  }

  Future<void> _report(BuildContext context) async {
    final bloc = context.read<OrderDetailBloc>();
    final reason = await DSBottomSheet.show<String>(
      context,
      title: context.l10N.orders_report_a_problem,
      child: const ReportProblemSheet(),
    );
    if (reason != null && reason.isNotEmpty) {
      bloc.add(OrderActionRequested(OrderAction.reportProblem, reason: reason));
    }
  }

  Future<void> _review(BuildContext context) async {
    final bloc = context.read<OrderDetailBloc>();
    final result = await DSBottomSheet.show<ReviewResult>(
      context,
      title: context.l10N.orders_leave_a_review,
      child: const ReviewSheet(),
    );
    if (result != null) {
      bloc.add(
        OrderActionRequested(
          OrderAction.review,
          rating: result.rating,
          body: result.body,
        ),
      );
    }
  }

  Future<void> _confirm(
    BuildContext context,
    String message,
    OrderAction action,
  ) async {
    final bloc = context.read<OrderDetailBloc>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        backgroundColor: DSColor.card,
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: dsFontFamily,
            color: DSColor.onSurface,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10N.orders_dialog_cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.l10N.orders_dialog_confirm),
          ),
        ],
      ),
    );
    if (ok == true) bloc.add(OrderActionRequested(action));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColor.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 22),
          onPressed: () => context.router.maybePop(),
        ),
        title: Text(context.l10N.orders_order_details),
      ),
      body: BlocBuilder<OrderDetailBloc, OrderDetailState>(
        builder: (BuildContext context, OrderDetailState state) {
          return switch (state) {
            OrderDetailLoadingState() => const DSLoader(),
            OrderDetailErrorState(:final type) => AppErrorWidget(
              type: type,
              onRetry: () =>
                  context.read<OrderDetailBloc>().add(OrderDetailStarted(id)),
            ),
            OrderDetailLoadedState() => _OrderBody(state: state),
          };
        },
      ),
      bottomNavigationBar: BlocBuilder<OrderDetailBloc, OrderDetailState>(
        builder: (BuildContext context, OrderDetailState state) {
          if (state is! OrderDetailLoadedState) return const SizedBox.shrink();
          final order = state.order;
          return OrderActionBarWidget(
            order: order,
            isActing: state.isActing,
            onShip: () => context.read<OrderDetailBloc>().add(
              const OrderActionRequested(OrderAction.ship),
            ),
            onConfirm: () => _confirm(
              context,
              context.l10N.orders_confirm_receipt_message,
              OrderAction.confirmReceipt,
            ),
            onCancel: () => _confirm(
              context,
              context.l10N.orders_cancel_order_message,
              OrderAction.cancel,
            ),
            onReport: () => _report(context),
            onReview: () => _review(context),
            onTrack: () => _open(context, order.tracking.liveTrackingUrl),
            onLabel: () => _open(context, order.tracking.labelUrl),
          );
        },
      ),
    );
  }
}

class _OrderBody extends StatelessWidget {
  final OrderDetailLoadedState state;

  const _OrderBody({required this.state});

  @override
  Widget build(BuildContext context) {
    final order = state.order;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: <Widget>[
        ...order.items.map((CartItem item) => _itemCard(context, item)),
        const SizedBox(height: 16),
        _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    context.l10N.orders_tracking,
                    style: const TextStyle(
                      fontFamily: dsFontFamily,
                      fontSize: DSFontSize.titleLarge,
                      fontWeight: DSFontWeight.semiBold,
                      color: DSColor.onSurface,
                    ),
                  ),
                  const Spacer(),
                  OrderStatusPillWidget(status: order.status),
                ],
              ),
              const SizedBox(height: 16),
              OrderTrackingStepperWidget(
                steps: buildEmxTrackingSteps(context.l10N, order.status),
              ),
              if (order.tracking.trackingNumber != null) ...<Widget>[
                const Divider(height: 24, color: DSColor.onSurface08),
                Row(
                  children: <Widget>[
                    Text(
                      context.l10N.orders_emx_tracking,
                      style: const TextStyle(
                        fontFamily: dsFontFamily,
                        fontSize: DSFontSize.bodyMedium,
                        color: DSColor.onSurface45,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      order.tracking.trackingNumber!,
                      style: const TextStyle(
                        fontFamily: dsFontFamily,
                        fontSize: DSFontSize.bodyMedium,
                        fontWeight: DSFontWeight.semiBold,
                        color: DSColor.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        OrderCounterpartCardWidget(
          party: order.counterpart,
          roleLabel: order.counterpartRoleLabel,
          onMessage: () => context.openChatWith(order.counterpart.id),
        ),
        if (order.deliveryAddress != null) ...<Widget>[
          const SizedBox(height: 16),
          _card(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: DSColor.onSurface45,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (order.deliveryName != null)
                        Text(
                          order.deliveryName!,
                          style: const TextStyle(
                            fontFamily: dsFontFamily,
                            fontSize: DSFontSize.bodyMedium,
                            fontWeight: DSFontWeight.semiBold,
                            color: DSColor.onSurface,
                          ),
                        ),
                      Text(
                        order.deliveryAddress!,
                        style: const TextStyle(
                          fontFamily: dsFontFamily,
                          fontSize: DSFontSize.bodyMedium,
                          color: DSColor.onSurface60,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.l10N.orders_emx_door_to_door,
                        style: const TextStyle(
                          fontFamily: dsFontFamily,
                          fontSize: DSFontSize.bodySmall,
                          color: DSColor.onSurface35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _card(Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DSColor.card,
        borderRadius: BorderRadius.circular(DSBorderRadius.card),
        border: Border.all(color: DSColor.onSurface07, width: 0.5),
      ),
      child: child,
    );
  }

  Widget _itemCard(BuildContext context, CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DSColor.card,
        borderRadius: BorderRadius.circular(DSBorderRadius.card),
        border: Border.all(color: DSColor.onSurface07, width: 0.5),
      ),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(DSBorderRadius.light),
            child: SizedBox(
              width: 60,
              height: 60,
              child: item.image == null
                  ? const ColoredBox(color: DSColor.lowBlack)
                  : Image.network(item.image!, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: dsFontFamily,
                    fontSize: DSFontSize.bodyLarge,
                    fontWeight: DSFontWeight.semiBold,
                    color: DSColor.onSurface,
                  ),
                ),
                if (item.meta.isNotEmpty)
                  Text(
                    item.meta,
                    style: const TextStyle(
                      fontFamily: dsFontFamily,
                      fontSize: DSFontSize.bodySmall,
                      color: DSColor.onSurface45,
                    ),
                  ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      context.l10N.orders_price_dhs(
                        item.effectivePrice.toInt(),
                      ),
                      style: const TextStyle(
                        fontFamily: dsFontFamily,
                        fontSize: DSFontSize.bodyMedium,
                        fontWeight: DSFontWeight.bold,
                        color: DSColor.onSurface,
                      ),
                    ),
                    // Accepted-offer items show the negotiated price plus a tag
                    // (design: small accent "Negotiated" label).
                    if (item.effectivePrice < item.price) ...<Widget>[
                      const SizedBox(width: 8),
                      Text(
                        context.l10N.orders_negotiated,
                        style: const TextStyle(
                          fontFamily: dsFontFamily,
                          fontSize: DSFontSize.bodySmall,
                          fontWeight: DSFontWeight.semiBold,
                          color: DSColor.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
