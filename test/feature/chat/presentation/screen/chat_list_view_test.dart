import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/core/components/app_error_widget.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_participant.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_thread.dart';
import 'package:klozy/src/feature/chat/presentation/bloc/chat_list/chat_list_bloc.dart';
import 'package:klozy/src/feature/chat/presentation/bloc/chat_list/chat_list_state.dart';
import 'package:klozy/src/feature/chat/presentation/screen/chat_list_view.dart';
import 'package:klozy/src/feature/chat/presentation/screen/states/chat_list_loading_widget.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/chat_list_row.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/empty_chats_widget.dart';
import 'package:klozy/src/router/app_router.dart';
import 'package:mocktail/mocktail.dart';

class _MockStackRouter extends Mock implements StackRouter {}

class _FakeChatListBloc extends Mock implements ChatListBloc {}

/// State-stubbed [ChatListBloc] mock. Faking the bloc (rather than subclassing
/// the real one) avoids the real constructor's stream/EventBus subscriptions,
/// which otherwise keep the test isolate alive and hang the suite.
_FakeChatListBloc _buildFakeChatListBloc(ChatListState state) {
  final _FakeChatListBloc bloc = _FakeChatListBloc();
  when(() => bloc.state).thenReturn(state);
  when(
    () => bloc.stream,
  ).thenAnswer((_) => const Stream<ChatListState>.empty());
  when(() => bloc.close()).thenAnswer((_) async {});
  return bloc;
}

Widget _wrap(ChatListBloc bloc, StackRouter router) {
  return BlocProvider<ChatListBloc>.value(
    value: bloc,
    child: MaterialApp(
      theme: dsTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: StackRouterScope(
        controller: router,
        stateHash: 0,
        child: const ChatListView(),
      ),
    ),
  );
}

const ChatThread _stubThread = ChatThread(
  id: 'thread-1',
  other: ChatParticipant(id: 'user-1', displayName: 'Alice'),
  hasLastMessage: true,
  lastMessageType: 'text',
  lastMessageText: 'Hello',
);

void main() {
  late _MockStackRouter router;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    registerFallbackValue(ChatThreadRoute(conversationId: 'x'));
  });

  setUp(() {
    router = _MockStackRouter();
    when(() => router.stateHash).thenReturn(0);
    when(
      () => router.push<Object?>(any(), onFailure: any(named: 'onFailure')),
    ).thenAnswer((_) async => null);
  });

  testWidgets('loading state shows ChatListLoadingWidget', (
    WidgetTester tester,
  ) async {
    final _FakeChatListBloc bloc = _buildFakeChatListBloc(
      const ChatListLoadingState(),
    );
    await tester.pumpWidget(_wrap(bloc, router));
    await tester.pump();

    expect(find.byType(ChatListLoadingWidget), findsOneWidget);
    expect(find.byType(AppErrorWidget), findsNothing);
    expect(find.byType(EmptyChatsWidget), findsNothing);
    await bloc.close();
  });

  testWidgets('error state shows AppErrorWidget', (WidgetTester tester) async {
    final _FakeChatListBloc bloc = _buildFakeChatListBloc(
      const ChatListErrorState(type: AppErrorType.unknown),
    );
    await tester.pumpWidget(_wrap(bloc, router));
    await tester.pump();

    expect(find.byType(AppErrorWidget), findsOneWidget);
    expect(find.byType(ChatListLoadingWidget), findsNothing);
    await bloc.close();
  });

  testWidgets('loaded empty state shows EmptyChatsWidget', (
    WidgetTester tester,
  ) async {
    final _FakeChatListBloc bloc = _buildFakeChatListBloc(
      const ChatListLoadedState(<ChatThread>[]),
    );
    await tester.pumpWidget(_wrap(bloc, router));
    await tester.pump();

    expect(find.byType(EmptyChatsWidget), findsOneWidget);
    expect(find.byType(ChatListRow), findsNothing);
    await bloc.close();
  });

  testWidgets('loaded non-empty state shows ChatListRow', (
    WidgetTester tester,
  ) async {
    final _FakeChatListBloc bloc = _buildFakeChatListBloc(
      const ChatListLoadedState(<ChatThread>[_stubThread]),
    );
    await tester.pumpWidget(_wrap(bloc, router));
    await tester.pump();

    expect(find.byType(ChatListRow), findsOneWidget);
    expect(find.byType(EmptyChatsWidget), findsNothing);
    await bloc.close();
  });

  testWidgets('loaded state with multiple threads renders a row per thread', (
    WidgetTester tester,
  ) async {
    const ChatThread second = ChatThread(
      id: 'thread-2',
      other: ChatParticipant(id: 'user-2', displayName: 'Bob'),
    );
    final _FakeChatListBloc bloc = _buildFakeChatListBloc(
      const ChatListLoadedState(<ChatThread>[_stubThread, second]),
    );
    await tester.pumpWidget(_wrap(bloc, router));
    await tester.pump();

    expect(find.byType(ChatListRow), findsNWidgets(2));
    await bloc.close();
  });
}
