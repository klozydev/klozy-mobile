import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/domain/orders/entity/order_status.dart';

class OrderStatusPillWidget extends StatelessWidget {
  final OrderStatus status;

  const OrderStatusPillWidget({super.key, required this.status});

  String _label(BuildContext context) {
    return switch (status) {
      OrderStatus.pending => context.l10N.orders_status_pending,
      OrderStatus.waitingForExpedition =>
        context.l10N.orders_status_awaiting_shipment,
      OrderStatus.inDelivery => context.l10N.orders_status_in_delivery,
      OrderStatus.deliveryCompleted =>
        context.l10N.orders_status_out_for_delivery,
      OrderStatus.completed => context.l10N.orders_status_completed,
      OrderStatus.returnRequested =>
        context.l10N.orders_status_return_requested,
      OrderStatus.canceled => context.l10N.orders_status_canceled,
      OrderStatus.unknown => context.l10N.orders_status_unknown,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(DSBorderRadius.chip),
      ),
      child: Text(
        _label(context).toUpperCase(),
        style: TextStyle(
          fontFamily: dsFontFamily,
          fontSize: 10,
          fontWeight: DSFontWeight.bold,
          letterSpacing: 0.4,
          color: status.color,
        ),
      ),
    );
  }
}
