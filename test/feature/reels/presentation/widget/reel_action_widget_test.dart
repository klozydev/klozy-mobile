import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/reels/presentation/widget/reel_action_widget.dart';

import '../../../../support/ds_harness.dart';

void main() {
  setUpAll(disableDsFonts);

  group('ReelActionWidget', () {
    testWidgets('renders icon with label', (WidgetTester tester) async {
      await tester.pumpWidget(
        dsWrap(
          ReelActionWidget(icon: Icons.favorite, label: '42', onTap: () {}),
          wrapInScaffold: true,
        ),
      );

      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('renders icon without label when label is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        dsWrap(
          ReelActionWidget(icon: Icons.more_horiz, onTap: () {}),
          wrapInScaffold: true,
        ),
      );

      expect(find.byIcon(Icons.more_horiz), findsOneWidget);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('calls onTap callback when tapped', (
      WidgetTester tester,
    ) async {
      int callCount = 0;
      await tester.pumpWidget(
        dsWrap(
          ReelActionWidget(
            icon: Icons.favorite_border,
            label: '0',
            onTap: () => callCount++,
          ),
          wrapInScaffold: true,
        ),
      );

      await tester.tap(find.byType(GestureDetector));
      expect(callCount, 1);
    });

    testWidgets('applies custom color to icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        dsWrap(
          ReelActionWidget(
            icon: Icons.favorite,
            color: Colors.red,
            onTap: () {},
          ),
          wrapInScaffold: true,
        ),
      );

      final Icon icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.color, Colors.red);
    });

    testWidgets('defaults color to white', (WidgetTester tester) async {
      await tester.pumpWidget(
        dsWrap(
          ReelActionWidget(icon: Icons.favorite, onTap: () {}),
          wrapInScaffold: true,
        ),
      );

      final Icon icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.color, Colors.white);
    });

    testWidgets('shows label text when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        dsWrap(
          ReelActionWidget(
            icon: Icons.shopping_bag_outlined,
            label: 'Shop',
            onTap: () {},
          ),
          wrapInScaffold: true,
        ),
      );

      expect(find.text('Shop'), findsOneWidget);
    });
  });
}
