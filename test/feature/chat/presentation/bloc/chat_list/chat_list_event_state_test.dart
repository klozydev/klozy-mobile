import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_thread.dart';
import 'package:klozy/src/feature/chat/presentation/bloc/chat_list/chat_list_event.dart';
import 'package:klozy/src/feature/chat/presentation/bloc/chat_list/chat_list_state.dart';

const _kThread = ChatThread(id: 'thread1');
const _kThreadWithUnread = ChatThread(id: 'thread2', unreadCount: 3);

void main() {
  group('ChatListEvent', () {
    group('ChatListStarted', () {
      test('props is empty', () {
        expect(const ChatListStarted().props, isEmpty);
      });

      test('two instances are equal', () {
        expect(const ChatListStarted(), const ChatListStarted());
      });
    });

    group('ChatListThreadsReceived', () {
      test('stores threads list', () {
        const event = ChatListThreadsReceived([_kThread]);
        expect(event.threads, [_kThread]);
      });

      test('stores empty list', () {
        expect(const ChatListThreadsReceived([]).threads, isEmpty);
      });

      test('props contains threads', () {
        expect(const ChatListThreadsReceived([_kThread]).props, [
          [_kThread],
        ]);
      });

      test('equal when same threads', () {
        expect(
          const ChatListThreadsReceived([_kThread]),
          const ChatListThreadsReceived([_kThread]),
        );
      });

      test('not equal for different threads', () {
        expect(
          const ChatListThreadsReceived([_kThread]),
          isNot(equals(const ChatListThreadsReceived([]))),
        );
      });
    });

    group('ChatListErrored', () {
      test('stores error', () {
        final error = Exception('oops');
        final event = ChatListErrored(error);
        expect(event.error, error);
      });

      test('props contains error', () {
        final error = Exception('oops');
        expect(ChatListErrored(error).props, [error]);
      });

      test('equal when same error instance', () {
        final error = Exception('oops');
        expect(ChatListErrored(error), ChatListErrored(error));
      });
    });
  });

  group('ChatListState', () {
    group('ChatListLoadingState', () {
      test('props is empty', () {
        expect(const ChatListLoadingState().props, isEmpty);
      });

      test('two instances are equal', () {
        expect(const ChatListLoadingState(), const ChatListLoadingState());
      });
    });

    group('ChatListErrorState', () {
      test('stores type', () {
        const state = ChatListErrorState(type: AppErrorType.network);
        expect(state.type, AppErrorType.network);
      });

      test('props contains type', () {
        expect(const ChatListErrorState(type: AppErrorType.server).props, [
          AppErrorType.server,
        ]);
      });

      test('equal when same type', () {
        expect(
          const ChatListErrorState(type: AppErrorType.unknown),
          const ChatListErrorState(type: AppErrorType.unknown),
        );
      });

      test('not equal for different type', () {
        expect(
          const ChatListErrorState(type: AppErrorType.network),
          isNot(equals(const ChatListErrorState(type: AppErrorType.server))),
        );
      });
    });

    group('ChatListLoadedState', () {
      test('stores threads', () {
        const state = ChatListLoadedState([_kThread]);
        expect(state.threads, [_kThread]);
      });

      test('props contains threads', () {
        expect(const ChatListLoadedState([_kThread]).props, [
          [_kThread],
        ]);
      });

      test('isEmpty returns true when threads empty', () {
        expect(const ChatListLoadedState([]).isEmpty, isTrue);
      });

      test('isEmpty returns false when threads non-empty', () {
        expect(const ChatListLoadedState([_kThread]).isEmpty, isFalse);
      });

      test('unreadCount returns 0 when no threads have unread', () {
        expect(const ChatListLoadedState([_kThread]).unreadCount, 0);
      });

      test('unreadCount counts one thread with unread messages', () {
        expect(
          const ChatListLoadedState([_kThread, _kThreadWithUnread]).unreadCount,
          1,
        );
      });

      test('unreadCount counts all threads with unread messages', () {
        const threadAlsoUnread = ChatThread(id: 'thread3', unreadCount: 1);
        expect(
          const ChatListLoadedState([
            _kThread,
            _kThreadWithUnread,
            threadAlsoUnread,
          ]).unreadCount,
          2,
        );
      });

      test('equal when same threads', () {
        expect(
          const ChatListLoadedState([_kThread]),
          const ChatListLoadedState([_kThread]),
        );
      });

      test('not equal for different threads', () {
        expect(
          const ChatListLoadedState([_kThread]),
          isNot(equals(const ChatListLoadedState([]))),
        );
      });
    });
  });
}
