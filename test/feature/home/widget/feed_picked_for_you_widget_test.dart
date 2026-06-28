import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/home/presentation/widget/feed_picked_for_you_widget.dart';

import '../../../support/ds_harness.dart';

void main() {
  setUpAll(() {
    disableDsFonts();
  });

  group('FeedPickedForYouWidget', () {
    testWidgets('renders categories joined by comma', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        dsWrap(
          const FeedPickedForYouWidget(categories: ['Women', 'Men']),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(find.textContaining('Women, Men'), findsOneWidget);
    });

    testWidgets('shows the auto_awesome icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        dsWrap(
          const FeedPickedForYouWidget(categories: ['Kids']),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
    });

    testWidgets('renders with single category', (WidgetTester tester) async {
      await tester.pumpWidget(
        dsWrap(
          const FeedPickedForYouWidget(categories: ['Women']),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(find.textContaining('Women'), findsOneWidget);
    });

    testWidgets('renders with empty categories list', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        dsWrap(
          const FeedPickedForYouWidget(categories: []),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      // No exception thrown and widget renders without crashing
      expect(find.byType(FeedPickedForYouWidget), findsOneWidget);
    });
  });
}
