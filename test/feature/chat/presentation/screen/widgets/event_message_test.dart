import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_message.dart';
import 'package:klozy/src/feature/chat/domain/entity/message_kind.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/event_message.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: dsTheme(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

const ChatMessage _eventMsg = ChatMessage(
  id: 'ev1',
  threadId: 'thread1',
  senderId: 'system',
  kind: ChatMessageKind.event,
  isMine: false,
  text: 'You started a conversation',
);

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('EventMessage', () {
    testWidgets('renders event text', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const EventMessage(message: _eventMsg)));
      await tester.pump();

      expect(find.text('You started a conversation'), findsOneWidget);
    });

    testWidgets('renders empty text when message.text is null', (
      WidgetTester tester,
    ) async {
      const ChatMessage noText = ChatMessage(
        id: 'ev2',
        threadId: 'thread1',
        senderId: 'system',
        kind: ChatMessageKind.event,
        isMine: false,
      );
      await tester.pumpWidget(_wrap(const EventMessage(message: noText)));
      await tester.pump();

      // Widget renders without error even with null text.
      expect(find.byType(EventMessage), findsOneWidget);
    });
  });
}
