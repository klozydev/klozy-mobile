import 'package:flutter/widgets.dart';

/// Order lifecycle status. Colours/labels mirror the prototype.
enum OrderStatus {
  pending('Pending', Color(0xFFE0A24D)),
  waitingForExpedition('Awaiting shipment', Color(0xFFE0A24D)),
  inDelivery('In delivery', Color(0xFFE0CE7D)),
  deliveryCompleted('Out for delivery', Color(0xFFE0CE7D)),
  completed('Completed', Color(0xFFA7D2BE)),
  returnRequested('Return requested', Color(0xFFEB5353)),
  canceled('Canceled', Color(0x73FFFFFF)),
  unknown('—', Color(0x73FFFFFF));

  final String label;
  final Color color;

  const OrderStatus(this.label, this.color);

  bool get isCompletedBucket =>
      this == OrderStatus.completed ||
      this == OrderStatus.canceled ||
      this == OrderStatus.returnRequested;

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
