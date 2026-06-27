import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_media.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_message.dart';
import 'package:klozy/src/feature/chat/domain/entity/media_type.dart';
import 'package:klozy/src/feature/chat/domain/entity/message_kind.dart';
import 'package:klozy/src/feature/chat/domain/entity/offer_data.dart';
import 'package:klozy/src/feature/chat/domain/entity/purchase_data.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/image_video_message.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/message_row.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: dsTheme(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: SingleChildScrollView(
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    ),
  ),
);

MessageRow _row(
  ChatMessage msg, {
  ValueChanged<ChatMessage>? onReply,
  ValueChanged<ChatMessage>? onOpenMedia,
  ValueChanged<ChatMessage>? onAcceptOffer,
  ValueChanged<ChatMessage>? onRefuseOffer,
  ValueChanged<String>? onQuotedTap,
}) => MessageRow(
  message: msg,
  onReply: onReply ?? (_) {},
  onOpenMedia: onOpenMedia ?? (_) {},
  onAcceptOffer: onAcceptOffer ?? (_) {},
  onRefuseOffer: onRefuseOffer ?? (_) {},
  onQuotedTap: onQuotedTap,
);

const ChatMessage _mine = ChatMessage(
  id: 'msg1',
  threadId: 'th1',
  senderId: 'me',
  kind: ChatMessageKind.text,
  isMine: true,
  text: 'My message',
  timeLabel: '10:00',
);

const ChatMessage _their = ChatMessage(
  id: 'msg2',
  threadId: 'th1',
  senderId: 'other',
  kind: ChatMessageKind.text,
  isMine: false,
  text: 'Their message',
  timeLabel: '10:01',
);

const ChatMessage _sending = ChatMessage(
  id: 'msg3',
  threadId: 'th1',
  senderId: 'me',
  kind: ChatMessageKind.text,
  isMine: true,
  text: 'Sending…',
  timeLabel: '10:02',
  sendStatus: 'sending',
);

const ChatMessage _failed = ChatMessage(
  id: 'msg4',
  threadId: 'th1',
  senderId: 'me',
  kind: ChatMessageKind.text,
  isMine: true,
  text: 'Failed',
  timeLabel: '10:03',
  sendStatus: 'failed',
);

const ChatMessage _deleted = ChatMessage(
  id: 'msg5',
  threadId: 'th1',
  senderId: 'other',
  kind: ChatMessageKind.deleted,
  isMine: false,
  timeLabel: '10:04',
);

const ChatMessage _image = ChatMessage(
  id: 'msg6',
  threadId: 'th1',
  senderId: 'me',
  kind: ChatMessageKind.image,
  isMine: true,
  timeLabel: '10:05',
);

const ChatMessage _video = ChatMessage(
  id: 'msg7',
  threadId: 'th1',
  senderId: 'other',
  kind: ChatMessageKind.video,
  isMine: false,
  timeLabel: '10:06',
);

const ChatMessage _audio = ChatMessage(
  id: 'msg8',
  threadId: 'th1',
  senderId: 'me',
  kind: ChatMessageKind.audio,
  isMine: true,
  timeLabel: '10:07',
  media: <ChatMedia>[ChatMedia(type: MediaType.audio, durationMs: 5000)],
);

const ChatMessage _file = ChatMessage(
  id: 'msg9',
  threadId: 'th1',
  senderId: 'other',
  kind: ChatMessageKind.file,
  isMine: false,
  timeLabel: '10:08',
  media: <ChatMedia>[ChatMedia(type: MediaType.other, name: 'doc.pdf')],
);

const ChatMessage _offer = ChatMessage(
  id: 'msg10',
  threadId: 'th1',
  senderId: 'other',
  kind: ChatMessageKind.offer,
  isMine: false,
  timeLabel: '10:09',
  offer: OfferData(
    offerId: 'o1',
    productName: 'Chair',
    listedPrice: 100,
    offerPrice: 80,
  ),
);

const ChatMessage _purchase = ChatMessage(
  id: 'msg11',
  threadId: 'th1',
  senderId: 'buyer',
  kind: ChatMessageKind.purchase,
  isMine: false,
  timeLabel: '10:10',
  purchase: PurchaseData(productName: 'Table', amount: 200),
);

const ChatMessage _event = ChatMessage(
  id: 'msg12',
  threadId: 'th1',
  senderId: 'system',
  kind: ChatMessageKind.event,
  isMine: false,
  text: 'Conversation started',
  timeLabel: '10:11',
);

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('MessageRow — text bubbles', () {
    testWidgets('renders mine text and time label', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(_row(_mine)));
      await tester.pump();

      expect(find.text('My message'), findsOneWidget);
      expect(find.text('10:00'), findsOneWidget);
    });

    testWidgets('renders their text and time label', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(_row(_their)));
      await tester.pump();

      expect(find.text('Their message'), findsOneWidget);
      expect(find.text('10:01'), findsOneWidget);
    });

    testWidgets('shows CircularProgressIndicator for sending status', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(_row(_sending)));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error icon for failed status', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(_row(_failed)));
      await tester.pump();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });

  group('MessageRow — deleted bubble', () {
    testWidgets('renders deleted message without Dismissible', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(_row(_deleted)));
      await tester.pumpAndSettle();

      // Deleted messages are centered and cannot be swiped.
      expect(find.byType(Dismissible), findsNothing);
    });
  });

  group('MessageRow — media kinds', () {
    testWidgets('renders image kind', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(_row(_image)));
      await tester.pump();

      expect(find.byType(MessageRow), findsOneWidget);
    });

    testWidgets('renders video kind with play icon', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(_row(_video)));
      await tester.pump();

      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('renders audio kind', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(_row(_audio)));
      await tester.pump();

      expect(find.byType(MessageRow), findsOneWidget);
    });

    testWidgets('renders file kind', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(_row(_file)));
      await tester.pump();

      expect(find.text('doc.pdf'), findsOneWidget);
    });

    testWidgets('renders offer kind', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(_row(_offer)));
      await tester.pumpAndSettle();

      expect(find.textContaining('80'), findsOneWidget);
    });

    testWidgets('renders purchase kind', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(_row(_purchase)));
      await tester.pumpAndSettle();

      expect(find.textContaining('Table'), findsOneWidget);
    });

    testWidgets('renders event kind', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(_row(_event)));
      await tester.pump();

      expect(find.text('Conversation started'), findsOneWidget);
    });
  });

  group('MessageRow — swipe-to-reply', () {
    testWidgets('wraps non-centered messages in Dismissible', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(_row(_mine)));
      await tester.pump();

      expect(find.byType(Dismissible), findsOneWidget);
    });

    testWidgets('does not wrap purchase (centered) in Dismissible', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(_row(_purchase)));
      await tester.pumpAndSettle();

      expect(find.byType(Dismissible), findsNothing);
    });

    testWidgets('does not wrap event (centered) in Dismissible', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(_row(_event)));
      await tester.pump();

      expect(find.byType(Dismissible), findsNothing);
    });

    testWidgets('calls onOpenMedia when image bubble tapped', (
      WidgetTester tester,
    ) async {
      ChatMessage? opened;
      await tester.pumpWidget(
        _wrap(_row(_image, onOpenMedia: (ChatMessage m) => opened = m)),
      );
      await tester.pump();

      // Tap anywhere inside the ImageVideoMessage subtree.
      await tester.tap(find.byType(ImageVideoMessage));
      expect(opened, equals(_image));
    });
  });
}
