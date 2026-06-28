import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/orders/entity/order_list_item.dart';
import 'package:klozy/src/domain/orders/entity/order_status.dart';
import 'package:klozy/src/feature/orders/presentation/widget/order_list_card_widget.dart';
import 'package:klozy/src/feature/orders/presentation/widget/order_status_pill_widget.dart';

import '../../../support/ds_harness.dart';

const _kItem = OrderListItem(
  id: 'o1',
  title: 'Cool Sneakers',
  price: 250,
  status: OrderStatus.pending,
  counterpartName: 'Alice',
  createdAtLabel: '2 days ago',
);

void main() {
  setUpAll(disableDsFonts);

  Widget build(OrderListItem item, {required VoidCallback onTap}) => dsWrap(
    OrderListCardWidget(order: item, counterpartPrefix: 'from', onTap: onTap),
    wrapInScaffold: true,
  );

  group('OrderListCardWidget', () {
    testWidgets('renders item title', (tester) async {
      await tester.pumpWidget(build(_kItem, onTap: () {}));
      await tester.pump();
      expect(find.text('Cool Sneakers'), findsOneWidget);
    });

    testWidgets('renders price in Dhs format', (tester) async {
      await tester.pumpWidget(build(_kItem, onTap: () {}));
      await tester.pump();
      expect(find.text('250 Dhs'), findsOneWidget);
    });

    testWidgets('renders OrderStatusPillWidget', (tester) async {
      await tester.pumpWidget(build(_kItem, onTap: () {}));
      await tester.pump();
      expect(find.byType(OrderStatusPillWidget), findsOneWidget);
    });

    testWidgets('renders counterpart meta with prefix', (tester) async {
      await tester.pumpWidget(build(_kItem, onTap: () {}));
      await tester.pump();
      expect(find.textContaining('from Alice'), findsOneWidget);
    });

    testWidgets('renders createdAtLabel in meta', (tester) async {
      await tester.pumpWidget(build(_kItem, onTap: () {}));
      await tester.pump();
      expect(find.textContaining('2 days ago'), findsOneWidget);
    });

    testWidgets('tapping the card fires onTap callback', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(build(_kItem, onTap: () => tapped = true));
      await tester.pump();
      await tester.tap(find.byType(OrderListCardWidget));
      expect(tapped, isTrue);
    });

    testWidgets('renders price truncated to int', (tester) async {
      const item = OrderListItem(
        id: 'o2',
        title: 'Jacket',
        price: 89.99,
        status: OrderStatus.inDelivery,
      );
      await tester.pumpWidget(build(item, onTap: () {}));
      await tester.pump();
      expect(find.text('89 Dhs'), findsOneWidget);
    });
  });
}
