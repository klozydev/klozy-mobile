import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/feature/orders/presentation/widget/refuse_return_sheet.dart';

import '../../../support/ds_harness.dart';

/// Pushes [RefuseReturnSheet] as a full-screen route and returns whatever
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
                builder: (_) => const Scaffold(body: RefuseReturnSheet()),
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

  group('RefuseReturnSheet', () {
    testWidgets('renders hint text in the text field', (tester) async {
      await tester.pumpWidget(_host((_) {}));
      await _showSheet(tester);
      expect(
        find.text("Explain why you're refusing this return"),
        findsOneWidget,
      );
    });

    testWidgets('shows validation message while field is empty', (
      tester,
    ) async {
      await tester.pumpWidget(_host((_) {}));
      await _showSheet(tester);
      expect(find.text('Add a reason before confirming'), findsOneWidget);
    });

    testWidgets('Confirm button is present', (tester) async {
      await tester.pumpWidget(_host((_) {}));
      await _showSheet(tester);
      expect(find.byType(DSButtonElevated), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);
    });

    testWidgets('Confirm button is disabled when field is empty', (
      tester,
    ) async {
      await tester.pumpWidget(_host((_) {}));
      await _showSheet(tester);
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('Confirm button becomes enabled and validation message hides '
        'after entering text', (tester) async {
      await tester.pumpWidget(_host((_) {}));
      await _showSheet(tester);

      await tester.enterText(find.byType(TextField), 'Item not damaged');
      await tester.pump();

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
      expect(find.text('Add a reason before confirming'), findsNothing);
    });

    testWidgets('tapping Confirm pops with the typed reason', (tester) async {
      String? popped;
      await tester.pumpWidget(_host((v) => popped = v));
      await _showSheet(tester);

      await tester.enterText(find.byType(TextField), 'Item shows heavy wear');
      await tester.pump();

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(popped, 'Item shows heavy wear');
    });

    testWidgets('tapping Confirm trims whitespace from input', (tester) async {
      String? popped;
      await tester.pumpWidget(_host((v) => popped = v));
      await _showSheet(tester);

      await tester.enterText(find.byType(TextField), '  not eligible  ');
      await tester.pump();

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(popped, 'not eligible');
    });

    testWidgets('never pops with an empty reason', (tester) async {
      await tester.pumpWidget(_host((_) {}));
      await _showSheet(tester);

      // Confirm is disabled while empty, so tapping it is a no-op — the
      // sheet stays open rather than popping an empty string.
      await tester.tap(find.text('Confirm'), warnIfMissed: false);
      await tester.pump();

      expect(find.byType(RefuseReturnSheet), findsOneWidget);
    });
  });
}
