import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/domain/orders/entity/order.dart';

const TextStyle _labelStyle = TextStyle(
  fontFamily: dsFontFamily,
  fontSize: DSFontSize.bodyMedium,
  color: DSColor.onSurface45,
);

const TextStyle _valueStyle = TextStyle(
  fontFamily: dsFontFamily,
  fontSize: DSFontSize.bodyMedium,
  fontWeight: DSFontWeight.semiBold,
  color: DSColor.onSurface,
);

/// Return-flow details: the buyer's [Order.returnReason], the seller's
/// [Order.returnRefuseReason] (once the return is refused), and the return
/// shipment's tracking number — all visible to both buyer and seller.
/// Renders nothing when none of the three fields are present.
class ReturnDetailsCardWidget extends StatelessWidget {
  final Order order;

  const ReturnDetailsCardWidget({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final String? reason = order.returnReason;
    final String? refuseReason = order.returnRefuseReason;
    final String? trackingNumber = order.tracking.returnTrackingNumber;

    if (reason == null && refuseReason == null && trackingNumber == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DSColor.card,
        borderRadius: BorderRadius.circular(DSBorderRadius.card),
        border: Border.all(color: DSColor.onSurface07, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (reason != null) ...<Widget>[
            Text(context.l10N.orders_return_reason_label, style: _labelStyle),
            const SizedBox(height: 4),
            Text(reason, style: _valueStyle),
          ],
          if (refuseReason != null) ...<Widget>[
            if (reason != null)
              const Divider(height: 24, color: DSColor.onSurface08),
            Text(context.l10N.orders_refuse_reason_label, style: _labelStyle),
            const SizedBox(height: 4),
            Text(refuseReason, style: _valueStyle),
          ],
          if (trackingNumber != null) ...<Widget>[
            if (reason != null || refuseReason != null)
              const Divider(height: 24, color: DSColor.onSurface08),
            Text(context.l10N.orders_return_tracking_label, style: _labelStyle),
            const SizedBox(height: 4),
            Text(trackingNumber, style: _valueStyle),
          ],
        ],
      ),
    );
  }
}
