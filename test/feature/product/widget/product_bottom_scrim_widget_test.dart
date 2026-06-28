import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/product/presentation/widget/product_bottom_scrim_widget.dart';

import '../../../support/ds_harness.dart';

void main() {
  setUpAll(disableDsFonts);

  group('ProductBottomScrimWidget', () {
    testWidgets('renders without crash', (WidgetTester tester) async {
      await tester.pumpWidget(
        dsWrap(const ProductBottomScrimWidget(), wrapInScaffold: true),
      );
      await tester.pump();

      expect(find.byType(ProductBottomScrimWidget), findsOneWidget);
    });

    testWidgets('uses FractionallySizedBox as root', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        dsWrap(const ProductBottomScrimWidget(), wrapInScaffold: true),
      );
      await tester.pump();

      expect(find.byType(FractionallySizedBox), findsOneWidget);
    });
  });
}
