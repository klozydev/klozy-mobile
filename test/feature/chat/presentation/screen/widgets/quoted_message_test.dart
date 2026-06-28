import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_message.dart';
import 'package:klozy/src/feature/chat/domain/entity/message_kind.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/quoted_message.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: dsTheme(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: Padding(padding: const EdgeInsets.all(16), child: child),
  ),
);

const ChatMessage _textReply = ChatMessage(
  id: 'r1',
  threadId: 'thread1',
  senderId: 'other',
  kind: ChatMessageKind.text,
  isMine: false,
  text: 'Hey this is the original message',
);

const ChatMessage _noTextReply = ChatMessage(
  id: 'r2',
  threadId: 'thread1',
  senderId: 'other',
  kind: ChatMessageKind.image,
  isMine: false,
);

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('QuotedMessage', () {
    testWidgets('renders reply text in "them" bubble context (mine=false)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(QuotedMessage(reply: _textReply, mine: false)),
      );
      await tester.pump();

      expect(find.text('Hey this is the original message'), findsOneWidget);
    });

    testWidgets('renders reply text in "mine" bubble context (mine=true)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(QuotedMessage(reply: _textReply, mine: true)),
      );
      await tester.pump();

      expect(find.text('Hey this is the original message'), findsOneWidget);
    });

    testWidgets('falls back to [media] when message text is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(QuotedMessage(reply: _noTextReply, mine: false)),
      );
      await tester.pump();

      expect(find.text('[media]'), findsOneWidget);
    });

    testWidgets('fires onTap callback when tapped', (
      WidgetTester tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          QuotedMessage(
            reply: _textReply,
            mine: false,
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byType(QuotedMessage));
      expect(tapped, isTrue);
    });
  });
}
