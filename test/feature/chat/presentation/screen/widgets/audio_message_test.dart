import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_media.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_message.dart';
import 'package:klozy/src/feature/chat/domain/entity/media_type.dart';
import 'package:klozy/src/feature/chat/domain/entity/message_kind.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/audio_message.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/audio_waveform.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: dsTheme(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: Padding(padding: const EdgeInsets.all(16), child: child),
  ),
);

const ChatMessage _mineAudio = ChatMessage(
  id: 'a1',
  threadId: 'th1',
  senderId: 'me',
  kind: ChatMessageKind.audio,
  isMine: true,
  media: <ChatMedia>[ChatMedia(type: MediaType.audio, durationMs: 7000)],
);

const ChatMessage _theirAudio = ChatMessage(
  id: 'a2',
  threadId: 'th1',
  senderId: 'other',
  kind: ChatMessageKind.audio,
  isMine: false,
  media: <ChatMedia>[ChatMedia(type: MediaType.audio, durationMs: 3500)],
);

const ChatMessage _noMediaAudio = ChatMessage(
  id: 'a3',
  threadId: 'th1',
  senderId: 'me',
  kind: ChatMessageKind.audio,
  isMine: true,
);

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('AudioMessage', () {
    testWidgets('renders play icon in initial (idle) state for mine', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(AudioMessage(message: _mineAudio)));
      await tester.pump();

      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('renders play icon in initial (idle) state for them', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(AudioMessage(message: _theirAudio)));
      await tester.pump();

      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('renders AudioWaveform', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(AudioMessage(message: _mineAudio)));
      await tester.pump();

      expect(find.byType(AudioWaveform), findsOneWidget);
    });

    testWidgets('renders duration label for 7 seconds', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(AudioMessage(message: _mineAudio)));
      await tester.pump();

      expect(find.text('0:07'), findsOneWidget);
    });

    testWidgets('renders duration label for 3.5 seconds (rounds to 4)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(AudioMessage(message: _theirAudio)));
      await tester.pump();

      // 3500ms → 4 seconds → 0:04.
      expect(find.text('0:04'), findsOneWidget);
    });

    testWidgets('renders 0:00 when no media', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(AudioMessage(message: _noMediaAudio)));
      await tester.pump();

      expect(find.text('0:00'), findsOneWidget);
    });

    testWidgets('widget disposes without error', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(AudioMessage(message: _mineAudio)));
      await tester.pump();

      // Replace the widget tree to trigger dispose.
      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      // No assertion — just confirm no exception is thrown on dispose.
    });
  });
}
