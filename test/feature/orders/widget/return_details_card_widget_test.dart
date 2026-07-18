import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/orders/entity/order.dart';
import 'package:klozy/src/domain/orders/entity/order_action.dart';
import 'package:klozy/src/domain/orders/entity/order_status.dart';
import 'package:klozy/src/domain/orders/entity/order_tracking.dart';
import 'package:klozy/src/domain/product/entity/product_detail.dart';
import 'package:klozy/src/feature/orders/presentation/widget/return_details_card_widget.dart';

import '../../../support/ds_harness.dart';

const _kSeller = ProductSeller(id: 's1', displayName: 'Alice');

Order _order({
  String? returnReason,
  String? returnRefuseReason,
  OrderTracking tracking = const OrderTracking(),
}) => Order(
  id: 'o1',
  status: OrderStatus.returnRequested,
  viewerRole: OrderRole.buyer,
  counterpart: _kSeller,
  returnReason: returnReason,
  returnRefuseReason: returnRefuseReason,
  tracking: tracking,
);

Widget _build(Order order) =>
    dsWrap(ReturnDetailsCardWidget(order: order), wrapInScaffold: true);

void main() {
  setUpAll(disableDsFonts);

  group('ReturnDetailsCardWidget', () {
    testWidgets('renders nothing when no return fields are present', (
      tester,
    ) async {
      await tester.pumpWidget(_build(_order()));
      await tester.pump();
      expect(find.text('Return reason'), findsNothing);
      expect(find.text('Refuse reason'), findsNothing);
      expect(find.text('Return tracking'), findsNothing);
    });

    testWidgets('shows return reason when present', (tester) async {
      await tester.pumpWidget(_build(_order(returnReason: 'Wrong size')));
      await tester.pump();
      expect(find.text('Return reason'), findsOneWidget);
      expect(find.text('Wrong size'), findsOneWidget);
    });

    testWidgets('shows refuse reason when present', (tester) async {
      await tester.pumpWidget(
        _build(_order(returnRefuseReason: 'Item shows signs of wear')),
      );
      await tester.pump();
      expect(find.text('Refuse reason'), findsOneWidget);
      expect(find.text('Item shows signs of wear'), findsOneWidget);
    });

    testWidgets('shows return tracking number when present', (tester) async {
      await tester.pumpWidget(
        _build(
          _order(
            tracking: const OrderTracking(returnTrackingNumber: 'RET-123'),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Return tracking'), findsOneWidget);
      expect(find.text('RET-123'), findsOneWidget);
    });

    testWidgets('shows all three fields together', (tester) async {
      await tester.pumpWidget(
        _build(
          _order(
            returnReason: 'Wrong size',
            returnRefuseReason: 'Item shows signs of wear',
            tracking: const OrderTracking(returnTrackingNumber: 'RET-123'),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Return reason'), findsOneWidget);
      expect(find.text('Refuse reason'), findsOneWidget);
      expect(find.text('Return tracking'), findsOneWidget);
      expect(find.byType(Divider), findsNWidgets(2));
    });
  });
}
