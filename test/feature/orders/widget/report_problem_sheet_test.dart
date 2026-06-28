import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/feature/orders/presentation/widget/report_problem_sheet.dart';

import '../../../support/ds_harness.dart';

/// Pushes [ReportProblemSheet] as a full-screen route and returns whatever
/// value was passed to [Navigator.pop].
Widget _host(void Function(String?) onPopped) {
  return MaterialApp(
    theme: dsTheme(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(
      builder: (ctx) => Scaffold(
        body: ElevatedButton(
          onPressed: () async {
            final result = await Navigator.of(ctx).push<String>(
              MaterialPageRoute<String>(
                builder: (_) => const Scaffold(body: ReportProblemSheet()),
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

  group('ReportProblemSheet', () {
    testWidgets('renders hint text in the text field', (tester) async {
      await tester.pumpWidget(_host((_) {}));
      await _showSheet(tester);
      expect(
        find.text("Describe what's wrong with your order"),
        findsOneWidget,
      );
    });

    testWidgets('Submit report button is present', (tester) async {
      await tester.pumpWidget(_host((_) {}));
      await _showSheet(tester);
      expect(find.byType(DSButtonElevated), findsOneWidget);
      expect(find.text('Submit report'), findsOneWidget);
    });

    testWidgets('Submit button is disabled when field is empty', (
      tester,
    ) async {
      await tester.pumpWidget(_host((_) {}));
      await _showSheet(tester);
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('Submit button becomes enabled after entering text', (
      tester,
    ) async {
      await tester.pumpWidget(_host((_) {}));
      await _showSheet(tester);

      await tester.enterText(find.byType(TextField), 'Item broken');
      await tester.pump();

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('tapping Submit pops with the typed text', (tester) async {
      String? popped;
      await tester.pumpWidget(_host((v) => popped = v));
      await _showSheet(tester);

      await tester.enterText(find.byType(TextField), 'Wrong item received');
      await tester.pump();

      await tester.tap(find.text('Submit report'));
      await tester.pumpAndSettle();

      expect(popped, 'Wrong item received');
    });

    testWidgets('tapping Submit trims whitespace from input', (tester) async {
      String? popped;
      await tester.pumpWidget(_host((v) => popped = v));
      await _showSheet(tester);

      await tester.enterText(find.byType(TextField), '  damaged  ');
      await tester.pump();

      await tester.tap(find.text('Submit report'));
      await tester.pumpAndSettle();

      expect(popped, 'damaged');
    });
  });
}
