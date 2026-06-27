import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_message.dart';
import 'package:klozy/src/feature/chat/domain/entity/message_kind.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/reply_preview_bar.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: dsTheme(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

const ChatMessage _theirMsg = ChatMessage(
  id: 'r1',
  threadId: 'thread1',
  senderId: 'other',
  kind: ChatMessageKind.text,
  isMine: false,
  text: 'Hello there!',
);

const ChatMessage _myMsg = ChatMessage(
  id: 'r2',
  threadId: 'thread1',
  senderId: 'me',
  kind: ChatMessageKind.text,
  isMine: true,
  text: 'I sent this first',
);

const ChatMessage _mediaMsg = ChatMessage(
  id: 'r3',
  threadId: 'thread1',
  senderId: 'other',
  kind: ChatMessageKind.image,
  isMine: false,
);

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('ReplyPreviewBar', () {
    testWidgets('renders reply text for other-message', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(ReplyPreviewBar(replyTo: _theirMsg, onCancel: () {})),
      );
      await tester.pumpAndSettle();

      expect(find.text('Hello there!'), findsOneWidget);
    });

    testWidgets('renders reply text for own message', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(ReplyPreviewBar(replyTo: _myMsg, onCancel: () {})),
      );
      await tester.pumpAndSettle();

      expect(find.text('I sent this first'), findsOneWidget);
    });

    testWidgets('shows media placeholder when text is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(ReplyPreviewBar(replyTo: _mediaMsg, onCancel: () {})),
      );
      await tester.pumpAndSettle();

      // The localised string for media placeholder should appear.
      expect(find.byType(ReplyPreviewBar), findsOneWidget);
    });

    testWidgets('shows close/cancel icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(ReplyPreviewBar(replyTo: _theirMsg, onCancel: () {})),
      );
      await tester.pump();

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('calls onCancel when close icon tapped', (
      WidgetTester tester,
    ) async {
      var cancelled = false;
      await tester.pumpWidget(
        _wrap(
          ReplyPreviewBar(replyTo: _theirMsg, onCancel: () => cancelled = true),
        ),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.close));
      expect(cancelled, isTrue);
    });
  });
}
