import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/core/util/relative_time_formatter.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/domain/orders/entity/order_list_item.dart';
import 'package:klozy/src/feature/orders/presentation/widget/order_status_pill_widget.dart';

class OrderListCardWidget extends StatelessWidget {
  final OrderListItem order;
  final String counterpartPrefix;
  final VoidCallback onTap;

  const OrderListCardWidget({
    super.key,
    required this.order,
    required this.counterpartPrefix,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
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
                child: order.coverImage == null
                    ? const ColoredBox(color: DSColor.lowBlack)
                    : Image.network(order.coverImage!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          order.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: dsFontFamily,
                            fontSize: DSFontSize.bodyLarge,
                            fontWeight: DSFontWeight.semiBold,
                            color: DSColor.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        context.l10N.orders_price_dhs(order.price.toInt()),
                        style: const TextStyle(
                          fontFamily: dsFontFamily,
                          fontSize: DSFontSize.bodyLarge,
                          fontWeight: DSFontWeight.bold,
                          color: DSColor.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _meta(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: dsFontFamily,
                      fontSize: DSFontSize.bodySmall,
                      color: DSColor.onSurface45,
                    ),
                  ),
                  const SizedBox(height: 7),
                  // Status pill sits below the title/meta (design), not pinned
                  // to the card's right edge.
                  OrderStatusPillWidget(status: order.status),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _meta(BuildContext context) {
    final String? createdLabel =
        order.createdAtLabel ??
        (order.createdAt != null
            ? RelativeTimeFormatter.format(context, order.createdAt!)
            : null);
    final parts = <String>[
      if (order.counterpartName.isNotEmpty)
        context.l10N.orders_counterpart_meta(
          counterpartPrefix,
          order.counterpartName,
        ),
      if (createdLabel != null) createdLabel,
    ];
    return parts.join(' · ');
  }
}
