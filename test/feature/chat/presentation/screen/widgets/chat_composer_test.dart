import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_outgoing_media.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/chat_composer.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/composer_bar.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/recording_bar.dart';

Widget _wrap({
  VoidCallback? onAttach,
  ValueChanged<String>? onSendText,
  ValueChanged<ChatOutgoingMedia>? onSendAudio,
}) => MaterialApp(
  theme: dsTheme(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: ChatComposer(
      onAttach: onAttach ?? () {},
      onSendText: onSendText ?? (_) {},
      onSendAudio: onSendAudio ?? (_) {},
    ),
  ),
);

// Note: ChatComposer owns an AudioRecorder (platform API). The recorder is not
// exercised in widget tests — tests only cover the idle (ComposerBar) state and
// the disposal path.

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('ChatComposer', () {
    testWidgets('shows ComposerBar in idle state', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      expect(find.byType(ComposerBar), findsOneWidget);
      expect(find.byType(RecordingBar), findsNothing);
    });

    testWidgets('forwards onAttach to ComposerBar', (
      WidgetTester tester,
    ) async {
      var attached = false;
      await tester.pumpWidget(_wrap(onAttach: () => attached = true));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.add));
      expect(attached, isTrue);
    });

    testWidgets('forwards onSendText when text sent', (
      WidgetTester tester,
    ) async {
      String? sent;
      await tester.pumpWidget(_wrap(onSendText: (String t) => sent = t));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'Chat test');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      expect(sent, equals('Chat test'));
    });

    testWidgets('disposes cleanly', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      // No error expected on dispose (recorder + timer + controller cleaned up).
    });
  });
}
