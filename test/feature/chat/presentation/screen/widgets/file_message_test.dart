import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_media.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_message.dart';
import 'package:klozy/src/feature/chat/domain/entity/media_type.dart';
import 'package:klozy/src/feature/chat/domain/entity/message_kind.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/file_message.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: dsTheme(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: Padding(padding: const EdgeInsets.all(16), child: child),
  ),
);

const ChatMessage _mineFile = ChatMessage(
  id: 'f1',
  threadId: 'thread1',
  senderId: 'me',
  kind: ChatMessageKind.file,
  isMine: true,
  media: <ChatMedia>[ChatMedia(name: 'contract.pdf', type: MediaType.other)],
);

const ChatMessage _theirFile = ChatMessage(
  id: 'f2',
  threadId: 'thread1',
  senderId: 'other',
  kind: ChatMessageKind.file,
  isMine: false,
  media: <ChatMedia>[ChatMedia(name: 'invoice.pdf', type: MediaType.other)],
);

const ChatMessage _noMediaFile = ChatMessage(
  id: 'f3',
  threadId: 'thread1',
  senderId: 'other',
  kind: ChatMessageKind.file,
  isMine: false,
);

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('FileMessage', () {
    testWidgets('renders filename for mine file', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const FileMessage(message: _mineFile)));
      await tester.pump();

      expect(find.text('contract.pdf'), findsOneWidget);
    });

    testWidgets('renders filename for their file', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const FileMessage(message: _theirFile)));
      await tester.pump();

      expect(find.text('invoice.pdf'), findsOneWidget);
    });

    testWidgets('falls back to "Attachment" when no media', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(const FileMessage(message: _noMediaFile)));
      await tester.pump();

      expect(find.text('Attachment'), findsOneWidget);
    });

    testWidgets('shows file icon', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const FileMessage(message: _mineFile)));
      await tester.pump();

      expect(find.byIcon(Icons.insert_drive_file_outlined), findsOneWidget);
    });

    testWidgets('calls onOpen when tapped', (WidgetTester tester) async {
      var opened = false;
      await tester.pumpWidget(
        _wrap(FileMessage(message: _theirFile, onOpen: () => opened = true)),
      );
      await tester.pump();

      await tester.tap(find.byType(FileMessage));
      expect(opened, isTrue);
    });
  });
}
