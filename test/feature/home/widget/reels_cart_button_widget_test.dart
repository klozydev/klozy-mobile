import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/home/presentation/widget/reels_cart_button_widget.dart';

import '../../../support/ds_harness.dart';

void main() {
  setUpAll(() {
    disableDsFonts();
  });

  group('ReelsCartButtonWidget', () {
    testWidgets('shows shopping bag icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        dsWrap(
          ReelsCartButtonWidget(count: 0, onTap: () {}),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
    });

    testWidgets('shows no badge when count is zero', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        dsWrap(
          ReelsCartButtonWidget(count: 0, onTap: () {}),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(find.text('0'), findsNothing);
    });

    testWidgets('shows badge text when count is positive', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        dsWrap(
          ReelsCartButtonWidget(count: 3, onTap: () {}),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('shows 9+ when count exceeds 9', (WidgetTester tester) async {
      await tester.pumpWidget(
        dsWrap(
          ReelsCartButtonWidget(count: 10, onTap: () {}),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(find.text('9+'), findsOneWidget);
    });

    testWidgets('exactly 9 shows as 9 not 9+', (WidgetTester tester) async {
      await tester.pumpWidget(
        dsWrap(
          ReelsCartButtonWidget(count: 9, onTap: () {}),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(find.text('9'), findsOneWidget);
      expect(find.text('9+'), findsNothing);
    });

    testWidgets('calls onTap when tapped', (WidgetTester tester) async {
      var tapped = false;
      await tester.pumpWidget(
        dsWrap(
          ReelsCartButtonWidget(count: 1, onTap: () => tapped = true),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      await tester.tap(find.byType(ReelsCartButtonWidget));
      expect(tapped, isTrue);
    });
  });
}
