import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_message.dart';
import 'package:klozy/src/feature/chat/domain/entity/message_kind.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/quoted_message.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/text_bubble.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: dsTheme(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: Padding(padding: const EdgeInsets.all(16), child: child),
  ),
);

const ChatMessage _mineText = ChatMessage(
  id: 'm1',
  threadId: 'thread1',
  senderId: 'me',
  kind: ChatMessageKind.text,
  isMine: true,
  text: 'Hello from me!',
);

const ChatMessage _theirText = ChatMessage(
  id: 'm2',
  threadId: 'thread1',
  senderId: 'other',
  kind: ChatMessageKind.text,
  isMine: false,
  text: 'Hello back!',
);

const ChatMessage _replyOriginal = ChatMessage(
  id: 'm0',
  threadId: 'thread1',
  senderId: 'other',
  kind: ChatMessageKind.text,
  isMine: false,
  text: 'Original message',
);

const ChatMessage _withReply = ChatMessage(
  id: 'm3',
  threadId: 'thread1',
  senderId: 'me',
  kind: ChatMessageKind.text,
  isMine: true,
  text: 'Reply body',
  replyTo: _replyOriginal,
);

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('TextBubble', () {
    testWidgets('renders mine bubble text', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const TextBubble(message: _mineText)));
      await tester.pump();

      expect(find.text('Hello from me!'), findsOneWidget);
    });

    testWidgets('renders their bubble text', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const TextBubble(message: _theirText)));
      await tester.pump();

      expect(find.text('Hello back!'), findsOneWidget);
    });

    testWidgets('renders QuotedMessage when replyTo is set', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(const TextBubble(message: _withReply)));
      await tester.pump();

      expect(find.byType(QuotedMessage), findsOneWidget);
      expect(find.text('Reply body'), findsOneWidget);
      expect(find.text('Original message'), findsOneWidget);
    });

    testWidgets('does not render QuotedMessage without reply', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(const TextBubble(message: _mineText)));
      await tester.pump();

      expect(find.byType(QuotedMessage), findsNothing);
    });

    testWidgets('fires onQuotedTap with reply id when quoted message tapped', (
      WidgetTester tester,
    ) async {
      String? tappedId;
      await tester.pumpWidget(
        _wrap(
          TextBubble(
            message: _withReply,
            onQuotedTap: (String id) => tappedId = id,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byType(QuotedMessage));
      expect(tappedId, equals('m0'));
    });
  });
}
