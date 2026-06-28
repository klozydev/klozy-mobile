import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/search/presentation/widget/price_range_section_widget.dart';

import '../../../../support/ds_harness.dart';

void main() {
  setUpAll(disableDsFonts);

  Widget build({
    double? min,
    double? max,
    double? low,
    double? high,
    ValueChanged<RangeValues>? onChanged,
  }) {
    return dsWrap(
      Scaffold(
        body: PriceRangeSectionWidget(
          min: min,
          max: max,
          low: low,
          high: high,
          onChanged: onChanged ?? (_) {},
        ),
      ),
    );
  }

  group('PriceRangeSectionWidget — invisible branches', () {
    testWidgets('renders SizedBox.shrink when min is null', (tester) async {
      await tester.pumpWidget(build(min: null, max: 200, low: 0, high: 200));
      await tester.pump();
      expect(find.byType(RangeSlider), findsNothing);
    });

    testWidgets('renders SizedBox.shrink when max is null', (tester) async {
      await tester.pumpWidget(build(min: 0, max: null, low: 0, high: 100));
      await tester.pump();
      expect(find.byType(RangeSlider), findsNothing);
    });

    testWidgets('renders SizedBox.shrink when hi <= lo (equal)', (
      tester,
    ) async {
      await tester.pumpWidget(
        build(min: 100.0, max: 100.0, low: 100.0, high: 100.0),
      );
      await tester.pump();
      expect(find.byType(RangeSlider), findsNothing);
    });

    testWidgets('renders SizedBox.shrink when hi < lo', (tester) async {
      await tester.pumpWidget(
        build(min: 200.0, max: 50.0, low: 50.0, high: 200.0),
      );
      await tester.pump();
      expect(find.byType(RangeSlider), findsNothing);
    });

    testWidgets('renders SizedBox.shrink when low is null', (tester) async {
      await tester.pumpWidget(
        build(min: 0.0, max: 200.0, low: null, high: 200.0),
      );
      await tester.pump();
      expect(find.byType(RangeSlider), findsNothing);
    });

    testWidgets('renders SizedBox.shrink when high is null', (tester) async {
      await tester.pumpWidget(
        build(min: 0.0, max: 200.0, low: 0.0, high: null),
      );
      await tester.pump();
      expect(find.byType(RangeSlider), findsNothing);
    });
  });

  group('PriceRangeSectionWidget — visible branch', () {
    testWidgets('renders RangeSlider when all values are valid', (
      tester,
    ) async {
      await tester.pumpWidget(
        build(min: 0.0, max: 500.0, low: 50.0, high: 300.0),
      );
      await tester.pump();
      expect(find.byType(RangeSlider), findsOneWidget);
    });

    testWidgets('RangeSlider onChanged is wired up', (tester) async {
      RangeValues? captured;
      await tester.pumpWidget(
        build(
          min: 0.0,
          max: 200.0,
          low: 10.0,
          high: 190.0,
          onChanged: (v) => captured = v,
        ),
      );
      await tester.pump();

      final slider = tester.widget<RangeSlider>(find.byType(RangeSlider));
      // Trigger callback directly to cover the onChanged branch.
      slider.onChanged!(const RangeValues(20.0, 180.0));
      expect(captured, const RangeValues(20.0, 180.0));
    });

    testWidgets('caps divisions at 200 for wide span', (tester) async {
      // span = 1000 > 200 → divisions clamped to 200
      await tester.pumpWidget(
        build(min: 0.0, max: 1000.0, low: 0.0, high: 1000.0),
      );
      await tester.pump();
      final slider = tester.widget<RangeSlider>(find.byType(RangeSlider));
      expect(slider.divisions, equals(200));
    });

    testWidgets('uses 1 division for a 1-unit span', (tester) async {
      // span = 1 → divisions = 1
      await tester.pumpWidget(build(min: 0.0, max: 1.0, low: 0.0, high: 1.0));
      await tester.pump();
      final slider = tester.widget<RangeSlider>(find.byType(RangeSlider));
      expect(slider.divisions, equals(1));
    });
  });
}
