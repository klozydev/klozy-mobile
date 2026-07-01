import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/product/presentation/widget/product_top_scrim_widget.dart';

import '../../../support/ds_harness.dart';

void main() {
  setUpAll(disableDsFonts);

  group('ProductTopScrimWidget', () {
    testWidgets('renders without crash', (WidgetTester tester) async {
      await tester.pumpWidget(
        dsWrap(const ProductTopScrimWidget(), wrapInScaffold: true),
      );
      await tester.pump();

      expect(find.byType(ProductTopScrimWidget), findsOneWidget);
    });

    testWidgets('is a Container with a gradient', (WidgetTester tester) async {
      await tester.pumpWidget(
        dsWrap(const ProductTopScrimWidget(), wrapInScaffold: true),
      );
      await tester.pump();

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.gradient, isA<LinearGradient>());
    });
  });
}
