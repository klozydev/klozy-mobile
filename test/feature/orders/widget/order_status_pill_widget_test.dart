import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/orders/entity/order_status.dart';
import 'package:klozy/src/feature/orders/presentation/widget/order_status_pill_widget.dart';

import '../../../support/ds_harness.dart';

void main() {
  setUpAll(disableDsFonts);

  Widget build(OrderStatus status) =>
      dsWrap(OrderStatusPillWidget(status: status), wrapInScaffold: true);

  group('OrderStatusPillWidget — label per status', () {
    testWidgets('pending shows PENDING', (tester) async {
      await tester.pumpWidget(build(OrderStatus.pending));
      await tester.pump();
      expect(find.text('PENDING'), findsOneWidget);
    });

    testWidgets('waitingForExpedition shows AWAITING SHIPMENT', (tester) async {
      await tester.pumpWidget(build(OrderStatus.waitingForExpedition));
      await tester.pump();
      expect(find.text('AWAITING SHIPMENT'), findsOneWidget);
    });

    testWidgets('inDelivery shows IN DELIVERY', (tester) async {
      await tester.pumpWidget(build(OrderStatus.inDelivery));
      await tester.pump();
      expect(find.text('IN DELIVERY'), findsOneWidget);
    });

    testWidgets('deliveryCompleted shows OUT FOR DELIVERY', (tester) async {
      await tester.pumpWidget(build(OrderStatus.deliveryCompleted));
      await tester.pump();
      expect(find.text('OUT FOR DELIVERY'), findsOneWidget);
    });

    testWidgets('completed shows COMPLETED', (tester) async {
      await tester.pumpWidget(build(OrderStatus.completed));
      await tester.pump();
      expect(find.text('COMPLETED'), findsOneWidget);
    });

    testWidgets('returnRequested shows RETURN REQUESTED', (tester) async {
      await tester.pumpWidget(build(OrderStatus.returnRequested));
      await tester.pump();
      expect(find.text('RETURN REQUESTED'), findsOneWidget);
    });

    testWidgets('returnAccepted shows RETURN ACCEPTED', (tester) async {
      await tester.pumpWidget(build(OrderStatus.returnAccepted));
      await tester.pump();
      expect(find.text('RETURN ACCEPTED'), findsOneWidget);
    });

    testWidgets('returnRefused shows RETURN REFUSED', (tester) async {
      await tester.pumpWidget(build(OrderStatus.returnRefused));
      await tester.pump();
      expect(find.text('RETURN REFUSED'), findsOneWidget);
    });

    testWidgets('returnCompleted shows RETURN COMPLETED', (tester) async {
      await tester.pumpWidget(build(OrderStatus.returnCompleted));
      await tester.pump();
      expect(find.text('RETURN COMPLETED'), findsOneWidget);
    });

    testWidgets('canceled shows CANCELED', (tester) async {
      await tester.pumpWidget(build(OrderStatus.canceled));
      await tester.pump();
      expect(find.text('CANCELED'), findsOneWidget);
    });

    testWidgets('unknown shows —', (tester) async {
      await tester.pumpWidget(build(OrderStatus.unknown));
      await tester.pump();
      expect(find.text('—'), findsOneWidget);
    });
  });
}
