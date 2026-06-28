import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/feature/orders/presentation/widget/review_sheet.dart';
import 'package:klozy/src/feature/orders/presentation/widget/star_rating_input.dart';

import '../../../support/ds_harness.dart';

Widget _host(void Function(ReviewResult?) onPopped) {
  return MaterialApp(
    theme: dsTheme(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(
      builder: (ctx) => Scaffold(
        body: ElevatedButton(
          onPressed: () async {
            final result = await Navigator.of(ctx).push<ReviewResult>(
              MaterialPageRoute<ReviewResult>(
                builder: (_) => const Scaffold(body: ReviewSheet()),
              ),
            );
            onPopped(result);
          },
          child: const Text('Show'),
        ),
      ),
    ),
  );
}

Future<void> _showSheet(WidgetTester tester) async {
  await tester.tap(find.text('Show'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(disableDsFonts);

  group('ReviewSheet', () {
    testWidgets('renders StarRatingInput', (tester) async {
      await tester.pumpWidget(_host((_) {}));
      await _showSheet(tester);
      expect(find.byType(StarRatingInput), findsOneWidget);
    });

    testWidgets('default rating is 5 (all filled stars)', (tester) async {
      await tester.pumpWidget(_host((_) {}));
      await _showSheet(tester);
      expect(find.byIcon(Icons.star_rounded), findsNWidgets(5));
      expect(find.byIcon(Icons.star_outline_rounded), findsNothing);
    });

    testWidgets('renders review hint text', (tester) async {
      await tester.pumpWidget(_host((_) {}));
      await _showSheet(tester);
      expect(
        find.text('Share details about your experience (optional)'),
        findsOneWidget,
      );
    });

    testWidgets('Submit review button is present', (tester) async {
      await tester.pumpWidget(_host((_) {}));
      await _showSheet(tester);
      expect(find.byType(DSButtonElevated), findsOneWidget);
      expect(find.text('Submit review'), findsOneWidget);
    });

    testWidgets('tapping Submit pops with default rating 5 and empty body', (
      tester,
    ) async {
      ReviewResult? popped;
      await tester.pumpWidget(_host((v) => popped = v));
      await _showSheet(tester);

      await tester.tap(find.text('Submit review'));
      await tester.pumpAndSettle();

      expect(popped?.rating, 5);
      expect(popped?.body, isEmpty);
    });

    testWidgets('tapping a star updates the rating', (tester) async {
      ReviewResult? popped;
      await tester.pumpWidget(_host((v) => popped = v));
      await _showSheet(tester);

      // Tap the second star in the 5-star row (index 1 → onChanged(2)).
      await tester.tap(find.byIcon(Icons.star_rounded).at(1));
      await tester.pump();

      await tester.tap(find.text('Submit review'));
      await tester.pumpAndSettle();

      expect(popped?.rating, 2);
    });

    testWidgets('entering body text is included in the result', (tester) async {
      ReviewResult? popped;
      await tester.pumpWidget(_host((v) => popped = v));
      await _showSheet(tester);

      await tester.enterText(find.byType(TextField), 'Great seller!');
      await tester.pump();

      await tester.tap(find.text('Submit review'));
      await tester.pumpAndSettle();

      expect(popped?.body, 'Great seller!');
    });
  });
}
