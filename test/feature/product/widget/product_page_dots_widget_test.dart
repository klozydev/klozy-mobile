import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/product/presentation/widget/product_page_dots_widget.dart';

import '../../../support/ds_harness.dart';

void main() {
  setUpAll(disableDsFonts);

  group('ProductPageDotsWidget', () {
    testWidgets('hides entirely when count is 1', (WidgetTester tester) async {
      await tester.pumpWidget(
        dsWrap(
          const ProductPageDotsWidget(count: 1, current: 0),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(find.byType(Row), findsNothing);
    });

    testWidgets('hides entirely when count is 0', (WidgetTester tester) async {
      await tester.pumpWidget(
        dsWrap(
          const ProductPageDotsWidget(count: 0, current: 0),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(find.byType(Row), findsNothing);
    });

    testWidgets('renders a Row with count children when count > 1', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        dsWrap(
          const ProductPageDotsWidget(count: 3, current: 0),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      final row = tester.widget<Row>(find.byType(Row).first);
      expect(row.children.length, 3);
    });

    testWidgets('renders correct number of dots for count=5', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        dsWrap(
          const ProductPageDotsWidget(count: 5, current: 2),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      final row = tester.widget<Row>(find.byType(Row).first);
      expect(row.children.length, 5);
    });
  });
}
