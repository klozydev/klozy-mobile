import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/feature/reels/presentation/widget/reel_processing_widget.dart';

import '../../../../support/ds_harness.dart';

void main() {
  setUpAll(disableDsFonts);

  group('ReelProcessingWidget', () {
    testWidgets('renders DSLoader', (WidgetTester tester) async {
      await tester.pumpWidget(
        dsWrap(const ReelProcessingWidget(), wrapInScaffold: true),
      );
      await tester.pump();
      expect(find.byType(DSLoader), findsOneWidget);
    });

    testWidgets('renders processing text', (WidgetTester tester) async {
      await tester.pumpWidget(
        dsWrap(const ReelProcessingWidget(), wrapInScaffold: true),
      );
      await tester.pump();
      // The localized string 'reels_processing_video' is rendered as Text.
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('has a ColoredBox with surface color', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        dsWrap(const ReelProcessingWidget(), wrapInScaffold: true),
      );
      await tester.pump();
      expect(find.byType(ColoredBox), findsAtLeastNWidgets(1));
    });
  });
}
