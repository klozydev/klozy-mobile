import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/product/entity/product_detail.dart';
import 'package:klozy/src/feature/product/presentation/widget/product_seller_card_widget.dart';

import '../../../support/ds_harness.dart';

void main() {
  setUpAll(disableDsFonts);

  group('ProductSellerCardWidget', () {
    testWidgets('shows seller display name', (WidgetTester tester) async {
      const seller = ProductSeller(id: 's1', displayName: 'Alice Martin');
      await tester.pumpWidget(
        dsWrap(
          ProductSellerCardWidget(
            seller: seller,
            isOwner: false,
            onMessage: () {},
          ),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(find.text('Alice Martin'), findsOneWidget);
    });

    testWidgets('shows chat icon for non-owner', (WidgetTester tester) async {
      const seller = ProductSeller(id: 's1', displayName: 'Bob');
      await tester.pumpWidget(
        dsWrap(
          ProductSellerCardWidget(
            seller: seller,
            isOwner: false,
            onMessage: () {},
          ),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.chat_bubble_outline_rounded), findsOneWidget);
    });

    testWidgets('hides chat icon when viewer is owner', (
      WidgetTester tester,
    ) async {
      const seller = ProductSeller(id: 's1', displayName: 'Bob');
      await tester.pumpWidget(
        dsWrap(
          ProductSellerCardWidget(
            seller: seller,
            isOwner: true,
            onMessage: () {},
          ),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.chat_bubble_outline_rounded), findsNothing);
    });

    testWidgets('onMessage fires when chat button is tapped', (
      WidgetTester tester,
    ) async {
      var called = false;
      const seller = ProductSeller(id: 's1', displayName: 'Carol');
      await tester.pumpWidget(
        dsWrap(
          ProductSellerCardWidget(
            seller: seller,
            isOwner: false,
            onMessage: () => called = true,
          ),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.chat_bubble_outline_rounded));
      await tester.pump();

      expect(called, isTrue);
    });

    testWidgets('shows PRO badge when seller isPro is true', (
      WidgetTester tester,
    ) async {
      const seller = ProductSeller(
        id: 's1',
        displayName: 'Pro Seller',
        isPro: true,
      );
      await tester.pumpWidget(
        dsWrap(
          ProductSellerCardWidget(
            seller: seller,
            isOwner: false,
            onMessage: () {},
          ),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(find.text('PRO'), findsOneWidget);
    });

    testWidgets('hides PRO badge when seller isPro is false', (
      WidgetTester tester,
    ) async {
      const seller = ProductSeller(
        id: 's1',
        displayName: 'Regular Seller',
        isPro: false,
      );
      await tester.pumpWidget(
        dsWrap(
          ProductSellerCardWidget(
            seller: seller,
            isOwner: false,
            onMessage: () {},
          ),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(find.text('PRO'), findsNothing);
    });
  });
}
