import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_thread.dart';
import 'package:klozy/src/feature/chat/domain/usecase/watch_threads.dart';
import 'package:klozy/src/feature/chat/presentation/bloc/chat_list/chat_list_bloc.dart';
import 'package:klozy/src/feature/chat/presentation/bloc/chat_list/chat_list_event.dart';
import 'package:klozy/src/feature/chat/presentation/bloc/chat_list/chat_list_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockWatchThreads extends Mock implements WatchThreads {}

const _kThread = ChatThread(id: 'thread1');

void main() {
  late _MockWatchThreads mockWatch;
  late ChatListBloc bloc;

  tearDown(() => bloc.close());

  test('initial state is ChatListLoadingState', () {
    mockWatch = _MockWatchThreads();
    when(
      () => mockWatch.call(),
    ).thenAnswer((_) => const Stream<List<ChatThread>>.empty());
    bloc = ChatListBloc(mockWatch, EventBus());
    expect(bloc.state, const ChatListLoadingState());
  });

  group('ChatListStarted', () {
    test('emits loaded state when stream emits threads', () async {
      final controller = StreamController<List<ChatThread>>.broadcast();
      mockWatch = _MockWatchThreads();
      when(() => mockWatch.call()).thenAnswer((_) => controller.stream);
      bloc = ChatListBloc(mockWatch, EventBus());

      final states = <ChatListState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const ChatListStarted());
      await Future<void>.delayed(Duration.zero);

      controller.add(const <ChatThread>[_kThread]);
      await Future<void>.delayed(Duration.zero);

      await sub.cancel();
      await controller.close();

      expect(states.first, const ChatListLoadingState());
      expect(
        states.any(
          (s) =>
              s is ChatListLoadedState &&
              s.threads.any((t) => t.id == 'thread1'),
        ),
        isTrue,
      );
    });

    test('emits error state when stream emits error', () async {
      final controller = StreamController<List<ChatThread>>.broadcast();
      mockWatch = _MockWatchThreads();
      when(() => mockWatch.call()).thenAnswer((_) => controller.stream);
      bloc = ChatListBloc(mockWatch, EventBus());

      final states = <ChatListState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const ChatListStarted());
      await Future<void>.delayed(Duration.zero);

      controller.addError(Exception('firestore'));
      await Future<void>.delayed(Duration.zero);

      await sub.cancel();
      await controller.close();

      expect(states.first, const ChatListLoadingState());
      expect(states.any((s) => s is ChatListErrorState), isTrue);
    });

    test(
      'emits loading then loaded when ChatListStarted re-triggers watch',
      () async {
        final controller = StreamController<List<ChatThread>>.broadcast();
        mockWatch = _MockWatchThreads();
        when(() => mockWatch.call()).thenAnswer((_) => controller.stream);
        bloc = ChatListBloc(mockWatch, EventBus());

        final states = <ChatListState>[];
        final sub = bloc.stream.listen(states.add);

        bloc.add(const ChatListStarted());
        await Future<void>.delayed(Duration.zero);

        controller.add(const <ChatThread>[_kThread]);
        await Future<void>.delayed(Duration.zero);

        expect(states.any((s) => s is ChatListLoadedState), isTrue);

        await sub.cancel();
        await controller.close();
      },
    );
  });
}
