import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/feature/reels/presentation/widget/reel_edit_sheet.dart';

import '../../../../support/ds_harness.dart';

void main() {
  setUpAll(disableDsFonts);

  group('ReelEditSheet', () {
    testWidgets('renders with no pre-filled caption', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        dsWrap(const ReelEditSheet(), wrapInScaffold: true),
      );
      await tester.pump();
      // Should show a text field and a save button.
      expect(find.byType(TextField), findsAtLeastNWidgets(1));
    });

    testWidgets('pre-fills provided caption', (WidgetTester tester) async {
      await tester.pumpWidget(
        dsWrap(
          const ReelEditSheet(caption: 'My caption'),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();
      expect(find.text('My caption'), findsOneWidget);
    });

    testWidgets('save button pops with trimmed text', (
      WidgetTester tester,
    ) async {
      String? popped;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  popped = await Navigator.of(context).push<String>(
                    MaterialPageRoute<String>(
                      builder: (_) => const Scaffold(
                        body: SingleChildScrollView(
                          child: ReelEditSheet(caption: 'hello '),
                        ),
                      ),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Find and tap the save button (DSButtonElevated uses Text for its label)
      // The l10n key is settings_save — find by icon or text inside ElevatedButton.
      final saveButton = find.byType(ElevatedButton).last;
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Route should have popped with the trimmed caption.
      expect(popped, 'hello');
    });

    testWidgets('save with empty caption pops with empty string', (
      WidgetTester tester,
    ) async {
      String? popped;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  popped = await Navigator.of(context).push<String>(
                    MaterialPageRoute<String>(
                      builder: (_) => const Scaffold(
                        body: SingleChildScrollView(child: ReelEditSheet()),
                      ),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final saveButton = find.byType(ElevatedButton).last;
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(popped, '');
    });
  });
}
