import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_bottom_bar.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_button_outline.dart';
import 'package:klozy/src/domain/orders/entity/order.dart';
import 'package:klozy/src/domain/orders/entity/order_action.dart';

/// Bottom action bar driven by `order.availableActions` (+ live-tracking/label
/// URLs). Primary action elevated, the rest outlined.
class OrderActionBarWidget extends StatelessWidget {
  final Order order;
  final bool isActing;
  final VoidCallback onShip;
  final VoidCallback onConfirm;
  final VoidCallback onReport;
  final VoidCallback onCancel;
  final VoidCallback onReview;
  final VoidCallback onTrack;
  final VoidCallback onLabel;

  const OrderActionBarWidget({
    super.key,
    required this.order,
    required this.isActing,
    required this.onShip,
    required this.onConfirm,
    required this.onReport,
    required this.onCancel,
    required this.onReview,
    required this.onTrack,
    required this.onLabel,
  });

  @override
  Widget build(BuildContext context) {
    final actions = order.availableActions;
    final buttons = <Widget>[];

    void primary(String text, VoidCallback onTap) => buttons.add(
      DSButtonElevated(text: text, isLoading: isActing, onPressed: onTap),
    );
    void secondary(String text, VoidCallback onTap) =>
        buttons.add(DSButtonOutline(text: text, onPressed: onTap));

    if (actions.contains(OrderAction.ship)) {
      primary(context.l10N.orders_mark_as_shipped, onShip);
      if (order.tracking.labelUrl != null) {
        secondary(context.l10N.orders_download_emx_label, onLabel);
      }
    }
    if (actions.contains(OrderAction.confirmReceipt)) {
      primary(context.l10N.orders_confirm_receipt, onConfirm);
    }
    if (actions.contains(OrderAction.review)) {
      primary(context.l10N.orders_leave_a_review, onReview);
    }
    if (order.tracking.liveTrackingUrl != null) {
      secondary(context.l10N.orders_view_live_tracking, onTrack);
    }
    if (actions.contains(OrderAction.reportProblem)) {
      secondary(context.l10N.orders_report_a_problem, onReport);
    }
    if (actions.contains(OrderAction.cancel)) {
      secondary(context.l10N.orders_cancel_order, onCancel);
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    return DSBottomBar(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (int i = 0; i < buttons.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(height: 10),
            buttons[i],
          ],
        ],
      ),
    );
  }
}
