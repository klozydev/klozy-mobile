import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/domain/orders/entity/order_status.dart';
import 'package:klozy/src/domain/orders/entity/order_tracking.dart';

/// Canonical EMX door-to-door flow shown on every order, with progress derived
/// from the order [status] (mirrors the prototype's `TRACK_TEMPLATE`). The four
/// steps are always rendered; [status] only decides which are done/active.
List<TrackingStep> buildEmxTrackingSteps(
  AppLocalizations l10n,
  OrderStatus status,
) {
  // Canonical step order. Statuses outside the happy path collapse to the end.
  const List<OrderStatus> order = <OrderStatus>[
    OrderStatus.waitingForExpedition,
    OrderStatus.inDelivery,
    OrderStatus.deliveryCompleted,
    OrderStatus.completed,
  ];

  final int index = switch (status) {
    OrderStatus.pending => 0,
    OrderStatus.waitingForExpedition => 0,
    OrderStatus.inDelivery => 1,
    OrderStatus.deliveryCompleted => 2,
    OrderStatus.completed ||
    OrderStatus.returnRequested ||
    OrderStatus.canceled => order.length - 1,
    OrderStatus.unknown => 0,
  };

  final List<(String, String)> copy = <(String, String)>[
    (l10n.orders_track_confirmed_label, l10n.orders_track_confirmed_sub),
    (l10n.orders_track_shipped_label, l10n.orders_track_shipped_sub),
    (l10n.orders_track_out_label, l10n.orders_track_out_sub),
    (l10n.orders_track_delivered_label, l10n.orders_track_delivered_sub),
  ];

  return <TrackingStep>[
    for (int i = 0; i < copy.length; i++)
      TrackingStep(
        label: copy[i].$1,
        sublabel: copy[i].$2,
        state: i < index
            ? TrackStepState.done
            : i == index
            ? TrackStepState.active
            : TrackStepState.pending,
      ),
  ];
}
