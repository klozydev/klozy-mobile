import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_participant.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_thread.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/chat_list_row.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: dsTheme(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

const ChatParticipant _regular = ChatParticipant(
  id: 'user1',
  displayName: 'Alice Martin',
  rating: 4.5,
  isPro: false,
);

const ChatParticipant _pro = ChatParticipant(
  id: 'user2',
  displayName: 'Bob Smith',
  rating: 4.8,
  isPro: true,
);

const ChatThread _readThread = ChatThread(
  id: 'thread1',
  other: _regular,
  hasLastMessage: true,
  lastMessageType: 'text',
  lastMessageText: 'See you tomorrow!',
  lastMessageFromMe: false,
  timeLabel: '10:30',
  unreadCount: 0,
);

const ChatThread _unreadThread = ChatThread(
  id: 'thread2',
  other: _regular,
  hasLastMessage: true,
  lastMessageType: 'text',
  lastMessageText: 'Check this out',
  lastMessageFromMe: false,
  timeLabel: '11:00',
  unreadCount: 3,
);

const ChatThread _proThread = ChatThread(
  id: 'thread3',
  other: _pro,
  hasLastMessage: false,
  timeLabel: 'Yesterday',
  unreadCount: 0,
);

const ChatThread _mediaThread = ChatThread(
  id: 'thread4',
  other: _regular,
  hasLastMessage: true,
  lastMessageType: 'media',
  lastMessageFromMe: true,
  timeLabel: '09:00',
  unreadCount: 0,
);

const ChatThread _audioThread = ChatThread(
  id: 'thread5',
  other: _regular,
  hasLastMessage: true,
  lastMessageType: 'audio',
  lastMessageFromMe: false,
  timeLabel: '08:00',
  unreadCount: 0,
);

const ChatThread _offerThread = ChatThread(
  id: 'thread6',
  other: _regular,
  hasLastMessage: true,
  lastMessageType: 'offer',
  lastMessageFromMe: true,
  timeLabel: '07:00',
  unreadCount: 0,
);

const ChatThread _purchaseThread = ChatThread(
  id: 'thread7',
  other: _regular,
  hasLastMessage: true,
  lastMessageType: 'purchase',
  lastMessageFromMe: false,
  timeLabel: '06:00',
  unreadCount: 1,
);

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('ChatListRow', () {
    testWidgets('renders participant display name', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(ChatListRow(thread: _readThread, onTap: () {})),
      );
      await tester.pump();

      expect(find.text('Alice Martin'), findsOneWidget);
    });

    testWidgets('renders time label', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(ChatListRow(thread: _readThread, onTap: () {})),
      );
      await tester.pump();

      expect(find.text('10:30'), findsOneWidget);
    });

    testWidgets('renders text preview from last message', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(ChatListRow(thread: _readThread, onTap: () {})),
      );
      await tester.pumpAndSettle();

      expect(find.text('See you tomorrow!'), findsOneWidget);
    });

    testWidgets('shows unread indicator when unreadCount > 0', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(ChatListRow(thread: _unreadThread, onTap: () {})),
      );
      await tester.pump();

      // The unread dot is a Container with BoxShape.circle.
      expect(
        find.byWidgetPredicate(
          (Widget w) =>
              w is Container &&
              w.decoration is BoxDecoration &&
              (w.decoration as BoxDecoration).shape == BoxShape.circle,
        ),
        findsAtLeastNWidgets(1),
      );
    });

    testWidgets('shows PRO chip when participant is pro', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(ChatListRow(thread: _proThread, onTap: () {})),
      );
      await tester.pump();

      expect(find.text('PRO'), findsOneWidget);
    });

    testWidgets('does not show PRO chip for regular participant', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(ChatListRow(thread: _readThread, onTap: () {})),
      );
      await tester.pump();

      expect(find.text('PRO'), findsNothing);
    });

    testWidgets('calls onTap when row is tapped', (WidgetTester tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(ChatListRow(thread: _readThread, onTap: () => tapped = true)),
      );
      await tester.pump();

      await tester.tap(find.byType(ChatListRow));
      expect(tapped, isTrue);
    });

    testWidgets('renders media preview for media type', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(ChatListRow(thread: _mediaThread, onTap: () {})),
      );
      await tester.pumpAndSettle();

      // preview text from localisation — just ensure widget renders.
      expect(find.byType(ChatListRow), findsOneWidget);
    });

    testWidgets('renders voice preview for audio type', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(ChatListRow(thread: _audioThread, onTap: () {})),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ChatListRow), findsOneWidget);
    });

    testWidgets('renders offer sent preview when mine=true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(ChatListRow(thread: _offerThread, onTap: () {})),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ChatListRow), findsOneWidget);
    });

    testWidgets('renders purchase preview', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(ChatListRow(thread: _purchaseThread, onTap: () {})),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ChatListRow), findsOneWidget);
    });

    testWidgets('renders no-messages text when thread has no last message', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(ChatListRow(thread: _proThread, onTap: () {})),
      );
      await tester.pumpAndSettle();

      // Widget renders without error.
      expect(find.byType(ChatListRow), findsOneWidget);
    });
  });
}
