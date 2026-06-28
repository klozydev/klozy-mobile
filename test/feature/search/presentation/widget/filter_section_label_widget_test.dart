import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/search/presentation/widget/filter_section_label_widget.dart';

import '../../../../support/ds_harness.dart';

void main() {
  setUpAll(disableDsFonts);

  group('FilterSectionLabelWidget', () {
    testWidgets('renders text uppercased', (tester) async {
      await tester.pumpWidget(
        dsWrap(
          const Scaffold(body: FilterSectionLabelWidget(text: 'category')),
        ),
      );
      await tester.pump();
      expect(find.text('CATEGORY'), findsOneWidget);
    });

    testWidgets('renders multi-word text uppercased', (tester) async {
      await tester.pumpWidget(
        dsWrap(
          const Scaffold(body: FilterSectionLabelWidget(text: 'price range')),
        ),
      );
      await tester.pump();
      expect(find.text('PRICE RANGE'), findsOneWidget);
    });

    testWidgets('already-uppercase text is still shown', (tester) async {
      await tester.pumpWidget(
        dsWrap(const Scaffold(body: FilterSectionLabelWidget(text: 'SIZE'))),
      );
      await tester.pump();
      expect(find.text('SIZE'), findsOneWidget);
    });

    testWidgets('widget exists in tree', (tester) async {
      await tester.pumpWidget(
        dsWrap(
          const Scaffold(body: FilterSectionLabelWidget(text: 'condition')),
        ),
      );
      await tester.pump();
      expect(find.byType(FilterSectionLabelWidget), findsOneWidget);
    });
  });
}
