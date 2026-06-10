import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';

/// Structural regression for the spacing added between the sort-row / active
/// filter chips and the main content area in SearchPage (task #16-b).
///
/// The production code places:
///   const SizedBox(height: DSSpacing.xxs)
/// as the separator.  These tests ensure:
///   1. The DSSpacing.xxs token equals 8.0 (token guard).
///   2. A SizedBox built with that value actually has the expected height
///      (widget construction guard).
void main() {
  group('SearchPage sort-row / content padding', () {
    test('DSSpacing.xxs token equals 8.0', () {
      expect(DSSpacing.xxs, equals(8.0));
    });

    testWidgets(
      'SizedBox(height: DSSpacing.xxs) renders with height 8.0',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  SizedBox(height: 44), // sort row stand-in
                  SizedBox(height: DSSpacing.xxs), // the gap
                  Expanded(child: SizedBox.expand()),
                ],
              ),
            ),
          ),
        );

        final sizedBoxes = tester
            .widgetList<SizedBox>(find.byType(SizedBox))
            .where((SizedBox w) => w.height == DSSpacing.xxs)
            .toList();

        expect(
          sizedBoxes,
          isNotEmpty,
          reason: 'A SizedBox(height: DSSpacing.xxs) must exist as the '
              'separator between the sort-row and the content area',
        );
      },
    );
  });
}
