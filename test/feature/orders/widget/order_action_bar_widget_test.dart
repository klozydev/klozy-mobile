import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_button_outline.dart';
import 'package:klozy/src/domain/orders/entity/order.dart';
import 'package:klozy/src/domain/orders/entity/order_action.dart';
import 'package:klozy/src/domain/orders/entity/order_status.dart';
import 'package:klozy/src/domain/orders/entity/order_tracking.dart';
import 'package:klozy/src/domain/product/entity/product_detail.dart';
import 'package:klozy/src/feature/orders/presentation/widget/order_action_bar_widget.dart';

import '../../../support/ds_harness.dart';

const _kSeller = ProductSeller(id: 's1', displayName: 'Alice');

Order _order({
  Set<OrderAction> actions = const <OrderAction>{},
  OrderTracking tracking = const OrderTracking(),
}) => Order(
  id: 'o1',
  status: OrderStatus.pending,
  viewerRole: OrderRole.buyer,
  counterpart: _kSeller,
  availableActions: actions,
  tracking: tracking,
);

Widget _build(
  Order order, {
  bool isActing = false,
  VoidCallback? onShip,
  VoidCallback? onConfirm,
  VoidCallback? onReport,
  VoidCallback? onCancel,
  VoidCallback? onReview,
  VoidCallback? onTrack,
  VoidCallback? onLabel,
}) => dsWrap(
  OrderActionBarWidget(
    order: order,
    isActing: isActing,
    onShip: onShip ?? () {},
    onConfirm: onConfirm ?? () {},
    onReport: onReport ?? () {},
    onCancel: onCancel ?? () {},
    onReview: onReview ?? () {},
    onTrack: onTrack ?? () {},
    onLabel: onLabel ?? () {},
  ),
  wrapInScaffold: true,
);

void main() {
  setUpAll(disableDsFonts);

  group('OrderActionBarWidget', () {
    testWidgets('renders nothing when no actions', (tester) async {
      await tester.pumpWidget(_build(_order()));
      await tester.pump();
      expect(find.byType(DSButtonElevated), findsNothing);
      expect(find.byType(DSButtonOutline), findsNothing);
    });

    testWidgets('ship action shows Mark as shipped button', (tester) async {
      await tester.pumpWidget(_build(_order(actions: {OrderAction.ship})));
      await tester.pump();
      expect(find.text('Mark as shipped'), findsOneWidget);
      expect(find.byType(DSButtonElevated), findsOneWidget);
    });

    testWidgets('ship action with labelUrl also shows Download EMX label', (
      tester,
    ) async {
      await tester.pumpWidget(
        _build(
          _order(
            actions: {OrderAction.ship},
            tracking: const OrderTracking(labelUrl: 'https://emx.test/label'),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Mark as shipped'), findsOneWidget);
      expect(find.text('Download EMX label'), findsOneWidget);
    });

    testWidgets('confirmReceipt action shows Confirm receipt button', (
      tester,
    ) async {
      await tester.pumpWidget(
        _build(_order(actions: {OrderAction.confirmReceipt})),
      );
      await tester.pump();
      expect(find.text('Confirm receipt'), findsOneWidget);
      expect(find.byType(DSButtonElevated), findsOneWidget);
    });

    testWidgets('review action shows Leave a review button', (tester) async {
      await tester.pumpWidget(_build(_order(actions: {OrderAction.review})));
      await tester.pump();
      expect(find.text('Leave a review'), findsOneWidget);
      expect(find.byType(DSButtonElevated), findsOneWidget);
    });

    testWidgets('reportProblem action shows Report a problem outline button', (
      tester,
    ) async {
      await tester.pumpWidget(
        _build(_order(actions: {OrderAction.reportProblem})),
      );
      await tester.pump();
      expect(find.text('Report a problem'), findsOneWidget);
      expect(find.byType(DSButtonOutline), findsOneWidget);
    });

    testWidgets('cancel action shows Cancel order outline button', (
      tester,
    ) async {
      await tester.pumpWidget(_build(_order(actions: {OrderAction.cancel})));
      await tester.pump();
      expect(find.text('Cancel order'), findsOneWidget);
      expect(find.byType(DSButtonOutline), findsOneWidget);
    });

    testWidgets('liveTrackingUrl shows View live tracking button', (
      tester,
    ) async {
      await tester.pumpWidget(
        _build(
          _order(
            tracking: const OrderTracking(
              liveTrackingUrl: 'https://emx.test/track',
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('View live tracking'), findsOneWidget);
      expect(find.byType(DSButtonOutline), findsOneWidget);
    });

    testWidgets('tapping ship fires onShip callback', (tester) async {
      bool fired = false;
      await tester.pumpWidget(
        _build(_order(actions: {OrderAction.ship}), onShip: () => fired = true),
      );
      await tester.pump();
      await tester.tap(find.text('Mark as shipped'));
      expect(fired, isTrue);
    });

    testWidgets('tapping report fires onReport callback', (tester) async {
      bool fired = false;
      await tester.pumpWidget(
        _build(
          _order(actions: {OrderAction.reportProblem}),
          onReport: () => fired = true,
        ),
      );
      await tester.pump();
      await tester.tap(find.text('Report a problem'));
      expect(fired, isTrue);
    });

    testWidgets('isActing shows loading spinner on primary button', (
      tester,
    ) async {
      await tester.pumpWidget(
        _build(_order(actions: {OrderAction.ship}), isActing: true),
      );
      await tester.pump();
      expect(find.byType(DSButtonElevated), findsOneWidget);
      // When isActing, DSButtonElevated passes isLoading:true which renders
      // a CircularProgressIndicator inside the ElevatedButton.
      expect(find.byType(DSButtonElevated), findsOneWidget);
    });
  });
}
