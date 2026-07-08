import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/orders/entity/order_status.dart';

void main() {
  group('OrderStatus.fromApi', () {
    test('parses pending and paid to pending', () {
      expect(OrderStatus.fromApi('pending'), OrderStatus.pending);
      expect(OrderStatus.fromApi('paid'), OrderStatus.pending);
    });

    test('parses waitingForExpedition variants', () {
      expect(
        OrderStatus.fromApi('waitingForExpedition'),
        OrderStatus.waitingForExpedition,
      );
      expect(
        OrderStatus.fromApi('awaiting_shipment'),
        OrderStatus.waitingForExpedition,
      );
      expect(
        OrderStatus.fromApi('awaitingShipment'),
        OrderStatus.waitingForExpedition,
      );
    });

    test('parses inDelivery / shipped to inDelivery', () {
      expect(OrderStatus.fromApi('inDelivery'), OrderStatus.inDelivery);
      expect(OrderStatus.fromApi('in_delivery'), OrderStatus.inDelivery);
      expect(OrderStatus.fromApi('shipped'), OrderStatus.inDelivery);
    });

    test('parses deliveryCompleted / outForDelivery to deliveryCompleted', () {
      expect(
        OrderStatus.fromApi('deliveryCompleted'),
        OrderStatus.deliveryCompleted,
      );
      expect(
        OrderStatus.fromApi('outForDelivery'),
        OrderStatus.deliveryCompleted,
      );
    });

    test('parses completed / delivered / confirmed to completed', () {
      expect(OrderStatus.fromApi('completed'), OrderStatus.completed);
      expect(OrderStatus.fromApi('delivered'), OrderStatus.completed);
      expect(OrderStatus.fromApi('confirmed'), OrderStatus.completed);
    });

    test('parses returnRequested / reported to returnRequested', () {
      expect(
        OrderStatus.fromApi('returnRequested'),
        OrderStatus.returnRequested,
      );
      expect(
        OrderStatus.fromApi('return_requested'),
        OrderStatus.returnRequested,
      );
      expect(OrderStatus.fromApi('reported'), OrderStatus.returnRequested);
    });

    test('parses canceled / cancelled to canceled', () {
      expect(OrderStatus.fromApi('canceled'), OrderStatus.canceled);
      expect(OrderStatus.fromApi('cancelled'), OrderStatus.canceled);
    });

    test('returns unknown for null', () {
      expect(OrderStatus.fromApi(null), OrderStatus.unknown);
    });

    test('returns unknown for unrecognised string', () {
      expect(OrderStatus.fromApi('foobar'), OrderStatus.unknown);
    });
  });

  group('OrderStatus.isCompletedBucket', () {
    test('completed is in the completed bucket', () {
      expect(OrderStatus.completed.isCompletedBucket, isTrue);
    });

    test('canceled is in the completed bucket', () {
      expect(OrderStatus.canceled.isCompletedBucket, isTrue);
    });

    test('returnRequested is in the completed bucket', () {
      expect(OrderStatus.returnRequested.isCompletedBucket, isTrue);
    });

    test('pending is NOT in the completed bucket', () {
      expect(OrderStatus.pending.isCompletedBucket, isFalse);
    });

    test('inDelivery is NOT in the completed bucket', () {
      expect(OrderStatus.inDelivery.isCompletedBucket, isFalse);
    });
  });

  group('OrderStatus color', () {
    test('every value has a non-null color', () {
      for (final OrderStatus s in OrderStatus.values) {
        expect(s.color, isNotNull);
      }
    });
  });
}
