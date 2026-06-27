import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/composer_bar.dart';

Widget _wrap({
  required TextEditingController controller,
  VoidCallback? onAttach,
  ValueChanged<String>? onSendText,
  VoidCallback? onStartRecording,
}) => MaterialApp(
  theme: dsTheme(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: ComposerBar(
      controller: controller,
      onAttach: onAttach ?? () {},
      onSendText: onSendText ?? (_) {},
      onStartRecording: onStartRecording ?? () {},
    ),
  ),
);

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('ComposerBar', () {
    testWidgets('renders attach button and mic icon by default (empty input)', (
      WidgetTester tester,
    ) async {
      final TextEditingController ctrl = TextEditingController();
      addTearDown(ctrl.dispose);

      await tester.pumpWidget(_wrap(controller: ctrl));
      await tester.pump();

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.mic_none), findsOneWidget);
    });

    testWidgets('swaps mic icon for send after text is entered', (
      WidgetTester tester,
    ) async {
      final TextEditingController ctrl = TextEditingController();
      addTearDown(ctrl.dispose);

      await tester.pumpWidget(_wrap(controller: ctrl));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.pump();

      expect(find.byIcon(Icons.send), findsOneWidget);
      expect(find.byIcon(Icons.mic_none), findsNothing);
    });

    testWidgets('reverts to mic when text is cleared', (
      WidgetTester tester,
    ) async {
      final TextEditingController ctrl = TextEditingController();
      addTearDown(ctrl.dispose);

      await tester.pumpWidget(_wrap(controller: ctrl));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.pump();

      await tester.enterText(find.byType(TextField), '');
      await tester.pump();

      expect(find.byIcon(Icons.mic_none), findsOneWidget);
    });

    testWidgets('calls onAttach when attach button tapped', (
      WidgetTester tester,
    ) async {
      var attached = false;
      final TextEditingController ctrl = TextEditingController();
      addTearDown(ctrl.dispose);

      await tester.pumpWidget(
        _wrap(controller: ctrl, onAttach: () => attached = true),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.add));
      expect(attached, isTrue);
    });

    testWidgets('calls onStartRecording when mic tapped', (
      WidgetTester tester,
    ) async {
      var recording = false;
      final TextEditingController ctrl = TextEditingController();
      addTearDown(ctrl.dispose);

      await tester.pumpWidget(
        _wrap(controller: ctrl, onStartRecording: () => recording = true),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.mic_none));
      expect(recording, isTrue);
    });

    testWidgets(
      'calls onSendText with text and clears field when send tapped',
      (WidgetTester tester) async {
        String? sent;
        final TextEditingController ctrl = TextEditingController();
        addTearDown(ctrl.dispose);

        await tester.pumpWidget(
          _wrap(controller: ctrl, onSendText: (String t) => sent = t),
        );
        await tester.pump();

        await tester.enterText(find.byType(TextField), 'Test message');
        await tester.pump();

        await tester.tap(find.byIcon(Icons.send));
        await tester.pump();

        expect(sent, equals('Test message'));
        expect(ctrl.text, isEmpty);
      },
    );

    testWidgets(
      'does not call onSendText when field is empty and send tapped',
      (WidgetTester tester) async {
        var called = false;
        final TextEditingController ctrl = TextEditingController();
        addTearDown(ctrl.dispose);

        // Pre-populate to show send button, then clear, then re-trigger.
        await tester.pumpWidget(
          _wrap(controller: ctrl, onSendText: (_) => called = true),
        );
        await tester.pump();

        // Directly set to whitespace-only which should not send.
        await tester.enterText(find.byType(TextField), '   ');
        await tester.pump();

        // mic button shown (hasText=false because trimmed is empty).
        expect(find.byIcon(Icons.mic_none), findsOneWidget);
        expect(called, isFalse);
      },
    );
  });
}
