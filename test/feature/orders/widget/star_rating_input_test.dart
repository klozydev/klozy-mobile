import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/orders/presentation/widget/star_rating_input.dart';

import '../../../support/ds_harness.dart';

void main() {
  setUpAll(disableDsFonts);

  Widget build(int rating, ValueChanged<int> onChanged) => dsWrap(
    StarRatingInput(rating: rating, onChanged: onChanged),
    wrapInScaffold: true,
  );

  group('StarRatingInput', () {
    testWidgets('rating 0 renders all 5 outline stars', (tester) async {
      await tester.pumpWidget(build(0, (_) {}));
      await tester.pump();
      expect(find.byIcon(Icons.star_outline_rounded), findsNWidgets(5));
      expect(find.byIcon(Icons.star_rounded), findsNothing);
    });

    testWidgets('rating 5 renders all 5 filled stars', (tester) async {
      await tester.pumpWidget(build(5, (_) {}));
      await tester.pump();
      expect(find.byIcon(Icons.star_rounded), findsNWidgets(5));
      expect(find.byIcon(Icons.star_outline_rounded), findsNothing);
    });

    testWidgets('rating 3 renders 3 filled and 2 outline stars', (
      tester,
    ) async {
      await tester.pumpWidget(build(3, (_) {}));
      await tester.pump();
      expect(find.byIcon(Icons.star_rounded), findsNWidgets(3));
      expect(find.byIcon(Icons.star_outline_rounded), findsNWidgets(2));
    });

    testWidgets('tapping first star fires onChanged(1)', (tester) async {
      int? received;
      await tester.pumpWidget(build(0, (v) => received = v));
      await tester.pump();
      // All stars are outline; tap the leftmost one (star 1).
      await tester.tap(find.byIcon(Icons.star_outline_rounded).first);
      expect(received, 1);
    });

    testWidgets('tapping third star fires onChanged(3)', (tester) async {
      int? received;
      await tester.pumpWidget(build(0, (v) => received = v));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.star_outline_rounded).at(2));
      expect(received, 3);
    });

    testWidgets('tapping fifth star fires onChanged(5)', (tester) async {
      int? received;
      await tester.pumpWidget(build(0, (v) => received = v));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.star_outline_rounded).last);
      expect(received, 5);
    });

    testWidgets('tapping star on already-filled row fires correct value', (
      tester,
    ) async {
      int? received;
      // rating:5 means all filled; tap the second filled star → onChanged(2)
      await tester.pumpWidget(build(5, (v) => received = v));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.star_rounded).at(1));
      expect(received, 2);
    });
  });
}
