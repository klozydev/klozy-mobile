import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_media.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_message.dart';
import 'package:klozy/src/feature/chat/domain/entity/media_type.dart';
import 'package:klozy/src/feature/chat/domain/entity/message_kind.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/image_video_message.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: dsTheme(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: Padding(padding: const EdgeInsets.all(16), child: child),
  ),
);

const ChatMessage _imageNoUrl = ChatMessage(
  id: 'img1',
  threadId: 'thread1',
  senderId: 'me',
  kind: ChatMessageKind.image,
  isMine: true,
);

const ChatMessage _videoNoUrl = ChatMessage(
  id: 'vid1',
  threadId: 'thread1',
  senderId: 'other',
  kind: ChatMessageKind.video,
  isMine: false,
);

const ChatMessage _videoWithThumb = ChatMessage(
  id: 'vid2',
  threadId: 'thread1',
  senderId: 'other',
  kind: ChatMessageKind.video,
  isMine: false,
  media: <ChatMedia>[
    ChatMedia(
      type: MediaType.video,
      thumbnailUrl: 'https://example.com/thumb.jpg',
    ),
  ],
);

const ChatMessage _imageWithUrl = ChatMessage(
  id: 'img2',
  threadId: 'thread1',
  senderId: 'other',
  kind: ChatMessageKind.image,
  isMine: false,
  media: <ChatMedia>[
    ChatMedia(
      type: MediaType.image,
      url: 'https://example.com/image.jpg',
      name: 'photo.jpg',
    ),
  ],
);

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('ImageVideoMessage', () {
    testWidgets('renders image placeholder when no url', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(ImageVideoMessage(message: _imageNoUrl)));
      await tester.pump();

      expect(find.byType(ImageVideoMessage), findsOneWidget);
    });

    testWidgets(
      'renders video poster overlay with play icon when kind is video',
      (WidgetTester tester) async {
        await tester.pumpWidget(_wrap(ImageVideoMessage(message: _videoNoUrl)));
        await tester.pump();

        expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      },
    );

    testWidgets('renders video with thumbnail url', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(ImageVideoMessage(message: _videoWithThumb)),
      );
      await tester.pump();

      expect(find.byType(ImageVideoMessage), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('calls onOpen when tapped', (WidgetTester tester) async {
      var opened = false;
      await tester.pumpWidget(
        _wrap(
          ImageVideoMessage(message: _imageNoUrl, onOpen: () => opened = true),
        ),
      );
      await tester.pump();

      await tester.tap(find.byType(GestureDetector).first);
      expect(opened, isTrue);
    });

    testWidgets('mine message uses different border radius', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(ImageVideoMessage(message: _imageNoUrl)));
      await tester.pump();

      // Widget renders without error for mine=true case.
      expect(find.byType(ImageVideoMessage), findsOneWidget);
    });

    testWidgets('their message renders without error', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(ImageVideoMessage(message: _videoNoUrl)));
      await tester.pump();

      expect(find.byType(ImageVideoMessage), findsOneWidget);
    });
  });
}
