import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/recording_bar.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: dsTheme(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('RecordingBar', () {
    testWidgets('renders elapsed label', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(RecordingBar(elapsed: '0:07', onCancel: () {}, onStop: () {})),
      );
      await tester.pump();

      expect(find.text('0:07'), findsOneWidget);
    });

    testWidgets('renders delete (cancel) and check (stop) icons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(RecordingBar(elapsed: '1:23', onCancel: () {}, onStop: () {})),
      );
      await tester.pump();

      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('calls onCancel when trash icon tapped', (
      WidgetTester tester,
    ) async {
      var cancelled = false;
      await tester.pumpWidget(
        _wrap(
          RecordingBar(
            elapsed: '0:05',
            onCancel: () => cancelled = true,
            onStop: () {},
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.delete_outline));
      expect(cancelled, isTrue);
    });

    testWidgets('calls onStop when check button tapped', (
      WidgetTester tester,
    ) async {
      var stopped = false;
      await tester.pumpWidget(
        _wrap(
          RecordingBar(
            elapsed: '0:10',
            onCancel: () {},
            onStop: () => stopped = true,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.check));
      expect(stopped, isTrue);
    });

    testWidgets('shows FadeTransition for the pulsing dot', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(RecordingBar(elapsed: '0:00', onCancel: () {}, onStop: () {})),
      );
      await tester.pump();

      expect(find.byType(FadeTransition), findsAtLeastNWidgets(1));
    });
  });
}
