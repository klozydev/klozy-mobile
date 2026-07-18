import 'package:flutter/widgets.dart';

/// Order lifecycle status. Colours mirror the prototype; the user-facing
/// label is resolved via l10n at the widget layer (see OrderStatusPillWidget),
/// so the enum only carries the display colour.
enum OrderStatus {
  pending(Color(0xFFE0A24D)),
  waitingForExpedition(Color(0xFFE0A24D)),
  inDelivery(Color(0xFFE0CE7D)),
  deliveryCompleted(Color(0xFFE0CE7D)),
  completed(Color(0xFFA7D2BE)),
  returnRequested(Color(0xFFEB5353)),
  returnAccepted(Color(0xFFE0A24D)),
  returnRefused(Color(0xFFEB5353)),
  returnCompleted(Color(0xFFA7D2BE)),
  canceled(Color(0x73FFFFFF)),
  unknown(Color(0x73FFFFFF));

  final Color color;

  const OrderStatus(this.color);

  bool get isCompletedBucket =>
      this == OrderStatus.completed ||
      this == OrderStatus.canceled ||
      this == OrderStatus.returnRequested ||
      this == OrderStatus.returnAccepted ||
      this == OrderStatus.returnRefused ||
      this == OrderStatus.returnCompleted;

  static OrderStatus fromApi(String? raw) {
    switch (_normalize(raw)) {
      case 'pending':
      case 'paid':
        return OrderStatus.pending;
      case 'waitingforexpedition':
      case 'awaitingshipment':
        return OrderStatus.waitingForExpedition;
      case 'indelivery':
      case 'shipped':
        return OrderStatus.inDelivery;
      case 'deliverycompleted':
      case 'outfordelivery':
        return OrderStatus.deliveryCompleted;
      case 'completed':
      case 'delivered':
      case 'confirmed':
        return OrderStatus.completed;
      case 'returnrequested':
      case 'reported':
        return OrderStatus.returnRequested;
      case 'returnaccepted':
        return OrderStatus.returnAccepted;
      case 'returnrefused':
        return OrderStatus.returnRefused;
      case 'returncompleted':
        return OrderStatus.returnCompleted;
      case 'canceled':
      case 'cancelled':
        return OrderStatus.canceled;
      default:
        return OrderStatus.unknown;
    }
  }

  static String _normalize(String? raw) =>
      (raw ?? '').toLowerCase().replaceAll(RegExp('[_-]'), '');
}
