import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/thread_menu_choice.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/thread_menu_sheet.dart';

Widget _wrapWithScaffold(Widget child) => MaterialApp(
  theme: dsTheme(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('ThreadMenuSheet', () {
    testWidgets('renders report and delete rows', (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithScaffold(const ThreadMenuSheet()));
      await tester.pumpAndSettle();

      // Both rows must be present (verified by icon presence).
      expect(find.byIcon(Icons.flag_outlined), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('pops ThreadMenuChoice.reportAndBlock when report row tapped', (
      WidgetTester tester,
    ) async {
      ThreadMenuChoice? result;

      await tester.pumpWidget(
        MaterialApp(
          theme: dsTheme(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (BuildContext context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    result = await showModalBottomSheet<ThreadMenuChoice>(
                      context: context,
                      builder: (_) => const ThreadMenuSheet(),
                    );
                  },
                  child: const Text('Open'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.flag_outlined));
      await tester.pumpAndSettle();

      expect(result, equals(ThreadMenuChoice.reportAndBlock));
    });

    testWidgets('pops ThreadMenuChoice.delete when delete row tapped', (
      WidgetTester tester,
    ) async {
      ThreadMenuChoice? result;

      await tester.pumpWidget(
        MaterialApp(
          theme: dsTheme(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (BuildContext context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    result = await showModalBottomSheet<ThreadMenuChoice>(
                      context: context,
                      builder: (_) => const ThreadMenuSheet(),
                    );
                  },
                  child: const Text('Open'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(result, equals(ThreadMenuChoice.delete));
    });
  });
}
