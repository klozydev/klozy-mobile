import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/product/entity/product_detail.dart';
import 'package:klozy/src/feature/orders/presentation/widget/order_counterpart_card_widget.dart';

import '../../../support/ds_harness.dart';

const _kParty = ProductSeller(id: 'seller-1', displayName: 'Jane Doe');

Widget _build({
  ProductSeller party = _kParty,
  String roleLabel = 'Seller',
  VoidCallback? onMessage,
}) => dsWrap(
  OrderCounterpartCardWidget(
    party: party,
    roleLabel: roleLabel,
    onMessage: onMessage ?? () {},
  ),
  wrapInScaffold: true,
);

void main() {
  setUpAll(disableDsFonts);

  group('OrderCounterpartCardWidget', () {
    testWidgets('renders display name', (tester) async {
      await tester.pumpWidget(_build());
      await tester.pump();
      expect(find.text('Jane Doe'), findsOneWidget);
    });

    testWidgets('renders role label', (tester) async {
      await tester.pumpWidget(_build(roleLabel: 'Seller'));
      await tester.pump();
      expect(find.text('Seller'), findsOneWidget);
    });

    testWidgets('renders buyer role label when provided', (tester) async {
      await tester.pumpWidget(_build(roleLabel: 'Buyer'));
      await tester.pump();
      expect(find.text('Buyer'), findsOneWidget);
    });

    testWidgets('tapping chat icon fires onMessage callback', (tester) async {
      bool messaged = false;
      await tester.pumpWidget(_build(onMessage: () => messaged = true));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.chat_bubble_outline_rounded));
      expect(messaged, isTrue);
    });

    testWidgets('shows person icon when avatar is null', (tester) async {
      const noAvatarParty = ProductSeller(
        id: 's2',
        displayName: 'No Avatar',
        avatarUrl: null,
      );
      await tester.pumpWidget(_build(party: noAvatarParty));
      await tester.pump();
      expect(find.byIcon(Icons.person), findsOneWidget);
    });
  });
}
