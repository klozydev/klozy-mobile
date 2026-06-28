import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/design/components/shimmer_box/shimmer_box_widget.dart';
import 'package:klozy/src/feature/notifications/presentation/widget/notification_skeleton_widget.dart';
import '../../../support/ds_harness.dart';

void main() {
  setUpAll(disableDsFonts);

  group('NotificationSkeletonWidget', () {
    testWidgets('renders 5 rows each with 4 ShimmerBoxWidgets (20 total)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(dsWrap(const NotificationSkeletonWidget()));
      // Advance time by 1ms to drain the Duration.zero timers created by
      // ShimmerBoxWidget.initState before assertions run.
      await tester.pump(const Duration(milliseconds: 1));

      // Each skeleton row: 1 avatar box + 3 body lines = 4 ShimmerBoxWidgets.
      // 5 rows × 4 = 20 total visible in the viewport.
      expect(find.byType(ShimmerBoxWidget), findsNWidgets(20));
    });

    testWidgets('is a ListView', (WidgetTester tester) async {
      await tester.pumpWidget(dsWrap(const NotificationSkeletonWidget()));
      await tester.pump(const Duration(milliseconds: 1));

      expect(find.byType(ListView), findsOneWidget);
    });
  });
}
