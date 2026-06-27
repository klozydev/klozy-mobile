import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/core/components/app_error_widget.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_message.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_participant.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_thread.dart';
import 'package:klozy/src/feature/chat/domain/entity/message_kind.dart';
import 'package:klozy/src/feature/chat/presentation/bloc/chat_thread/chat_thread_bloc.dart';
import 'package:klozy/src/feature/chat/presentation/bloc/chat_thread/chat_thread_state.dart';
import 'package:klozy/src/feature/chat/presentation/screen/chat_thread_page.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/message_row.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/reply_preview_bar.dart';
import 'package:klozy/src/router/app_router.dart';
import 'package:mocktail/mocktail.dart';

class _MockStackRouter extends Mock implements StackRouter {}

class _FakeChatThreadBloc extends Mock implements ChatThreadBloc {}

/// State-stubbed [ChatThreadBloc] mock. Faking the bloc (rather than
/// subclassing the real one) avoids the real constructor's stream/EventBus
/// subscriptions, which otherwise keep the test isolate alive and hang.
_FakeChatThreadBloc _buildFakeChatThreadBloc(ChatThreadState state) {
  final _FakeChatThreadBloc bloc = _FakeChatThreadBloc();
  when(() => bloc.state).thenReturn(state);
  when(
    () => bloc.stream,
  ).thenAnswer((_) => const Stream<ChatThreadState>.empty());
  when(() => bloc.close()).thenAnswer((_) async {});
  return bloc;
}

Widget _wrap(ChatThreadBloc bloc, StackRouter router) {
  return BlocProvider<ChatThreadBloc>.value(
    value: bloc,
    child: MaterialApp(
      theme: dsTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: StackRouterScope(
        controller: router,
        stateHash: 0,
        child: const ChatThreadPage(conversationId: 'test-convo'),
      ),
    ),
  );
}

const ChatParticipant _other = ChatParticipant(
  id: 'user-42',
  displayName: 'Alice',
);

const ChatThread _stubThread = ChatThread(id: 'test-convo', other: _other);

ChatMessage _stubMessage({String id = 'msg-1'}) => ChatMessage(
  id: id,
  threadId: 'test-convo',
  senderId: 'user-42',
  kind: ChatMessageKind.text,
  isMine: false,
  text: 'Hi there',
  timeLabel: '10:00',
);

void main() {
  late _MockStackRouter router;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    registerFallbackValue(UserProfileRoute(userId: 'x'));
  });

  setUp(() {
    router = _MockStackRouter();
    when(() => router.stateHash).thenReturn(0);
    when(
      () => router.push<Object?>(any(), onFailure: any(named: 'onFailure')),
    ).thenAnswer((_) async => null);
    when(() => router.maybePop<Object?>()).thenAnswer((_) async => false);
  });

  testWidgets('loading state shows DSLoader in body', (
    WidgetTester tester,
  ) async {
    final _FakeChatThreadBloc bloc = _buildFakeChatThreadBloc(
      const ChatThreadLoadingState(),
    );
    await tester.pumpWidget(_wrap(bloc, router));
    await tester.pump();

    expect(find.byType(DSLoader), findsOneWidget);
    expect(find.byType(AppErrorWidget), findsNothing);
    await bloc.close();
  });

  testWidgets('error state shows AppErrorWidget', (WidgetTester tester) async {
    final _FakeChatThreadBloc bloc = _buildFakeChatThreadBloc(
      const ChatThreadErrorState(type: AppErrorType.unknown),
    );
    await tester.pumpWidget(_wrap(bloc, router));
    await tester.pump();

    expect(find.byType(AppErrorWidget), findsOneWidget);
    expect(find.byType(DSLoader), findsNothing);
    await bloc.close();
  });

  testWidgets('loaded empty state renders no MessageRow and no DSLoader', (
    WidgetTester tester,
  ) async {
    final _FakeChatThreadBloc bloc = _buildFakeChatThreadBloc(
      const ChatThreadLoadedState(
        thread: _stubThread,
        messages: <ChatMessage>[],
      ),
    );
    await tester.pumpWidget(_wrap(bloc, router));
    await tester.pump();

    expect(find.byType(MessageRow), findsNothing);
    expect(find.byType(DSLoader), findsNothing);
    expect(find.byType(AppErrorWidget), findsNothing);
    await bloc.close();
  });

  testWidgets('loaded non-empty state renders MessageRow for each message', (
    WidgetTester tester,
  ) async {
    final ChatMessage msg = _stubMessage();
    final _FakeChatThreadBloc bloc = _buildFakeChatThreadBloc(
      ChatThreadLoadedState(thread: _stubThread, messages: <ChatMessage>[msg]),
    );
    await tester.pumpWidget(_wrap(bloc, router));
    await tester.pump();

    expect(find.byType(MessageRow), findsOneWidget);
    expect(find.byType(AppErrorWidget), findsNothing);
    await bloc.close();
  });

  testWidgets('loaded state with replyTo shows ReplyPreviewBar', (
    WidgetTester tester,
  ) async {
    final ChatMessage reply = _stubMessage(id: 'reply-msg');
    final _FakeChatThreadBloc bloc = _buildFakeChatThreadBloc(
      ChatThreadLoadedState(
        thread: _stubThread,
        messages: <ChatMessage>[_stubMessage()],
        replyTo: reply,
      ),
    );
    await tester.pumpWidget(_wrap(bloc, router));
    await tester.pump();

    expect(find.byType(ReplyPreviewBar), findsOneWidget);
    await bloc.close();
  });

  testWidgets('loaded state without replyTo hides ReplyPreviewBar', (
    WidgetTester tester,
  ) async {
    final _FakeChatThreadBloc bloc = _buildFakeChatThreadBloc(
      ChatThreadLoadedState(
        thread: _stubThread,
        messages: <ChatMessage>[_stubMessage()],
      ),
    );
    await tester.pumpWidget(_wrap(bloc, router));
    await tester.pump();

    expect(find.byType(ReplyPreviewBar), findsNothing);
    await bloc.close();
  });

  testWidgets('closed state calls router.maybePop', (
    WidgetTester tester,
  ) async {
    final _FakeChatThreadBloc bloc = _buildFakeChatThreadBloc(
      const ChatThreadClosedState(),
    );
    // Emit the closed state on the stream so the page's BlocListener fires.
    when(() => bloc.stream).thenAnswer(
      (_) => Stream<ChatThreadState>.value(const ChatThreadClosedState()),
    );
    await tester.pumpWidget(_wrap(bloc, router));
    await tester.pump();

    verify(() => router.maybePop<Object?>()).called(1);
    await bloc.close();
  });
}
