import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/reels/presentation/widget/reel_progress_dots_widget.dart';

import '../../../../support/ds_harness.dart';

void main() {
  setUpAll(disableDsFonts);

  group('ReelProgressDotsWidget', () {
    testWidgets('returns SizedBox.shrink when count is 0', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        dsWrap(const ReelProgressDotsWidget(count: 0, current: 0)),
      );

      expect(find.byType(Column), findsNothing);
      expect(find.byType(AnimatedContainer), findsNothing);
    });

    testWidgets('returns SizedBox.shrink when count is 1', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        dsWrap(const ReelProgressDotsWidget(count: 1, current: 0)),
      );

      expect(find.byType(Column), findsNothing);
      expect(find.byType(AnimatedContainer), findsNothing);
    });

    testWidgets('renders correct number of dots when count > 1', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        dsWrap(const ReelProgressDotsWidget(count: 3, current: 0)),
      );

      // One AnimatedContainer per dot.
      expect(find.byType(AnimatedContainer), findsNWidgets(3));
    });

    testWidgets('active dot is taller (height 18) than inactive dots (4)', (
      WidgetTester tester,
    ) async {
      const int count = 3;
      const int current = 1;
      await tester.pumpWidget(
        dsWrap(const ReelProgressDotsWidget(count: count, current: current)),
      );
      await tester.pump();

      final List<AnimatedContainer> containers = tester
          .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
          .toList();

      expect(containers.length, count);

      for (int i = 0; i < count; i++) {
        final AnimatedContainer c = containers[i];
        // Access height via BoxConstraints through the constraints on the
        // AnimatedContainer child.
        // Verify via the height key passed to the widget factory.
        // Height is exposed as a field on AnimatedContainer.
        // The AnimatedContainer encodes height via constraints.
        if (i == current) {
          // Active dot: the container has height 18.
          // We verify indirectly: the rendered size from the tester.
          final Size size = tester.getSize(find.byWidget(c));
          expect(size.height, greaterThanOrEqualTo(18));
        } else {
          final Size size = tester.getSize(find.byWidget(c));
          expect(size.height, lessThan(18));
        }
      }
    });

    testWidgets('first dot is active when current is 0', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        dsWrap(const ReelProgressDotsWidget(count: 3, current: 0)),
      );
      await tester.pump();

      final List<AnimatedContainer> containers = tester
          .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
          .toList();

      final Size firstSize = tester.getSize(find.byWidget(containers[0]));
      final Size secondSize = tester.getSize(find.byWidget(containers[1]));

      expect(firstSize.height, greaterThan(secondSize.height));
    });

    testWidgets('last dot is active when current equals count-1', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        dsWrap(const ReelProgressDotsWidget(count: 3, current: 2)),
      );
      await tester.pump();

      final List<AnimatedContainer> containers = tester
          .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
          .toList();

      final Size lastSize = tester.getSize(find.byWidget(containers[2]));
      final Size firstSize = tester.getSize(find.byWidget(containers[0]));

      expect(lastSize.height, greaterThan(firstSize.height));
    });

    testWidgets('renders 5 dots for count=5', (WidgetTester tester) async {
      await tester.pumpWidget(
        dsWrap(const ReelProgressDotsWidget(count: 5, current: 2)),
      );

      expect(find.byType(AnimatedContainer), findsNWidgets(5));
    });
  });
}
