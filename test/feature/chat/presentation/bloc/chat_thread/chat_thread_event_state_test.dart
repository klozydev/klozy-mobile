import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_message.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_outgoing_media.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_thread.dart';
import 'package:klozy/src/feature/chat/domain/entity/media_type.dart';
import 'package:klozy/src/feature/chat/domain/entity/message_kind.dart';
import 'package:klozy/src/feature/chat/presentation/bloc/chat_thread/chat_thread_event.dart';
import 'package:klozy/src/feature/chat/presentation/bloc/chat_thread/chat_thread_state.dart';

const _kMessage = ChatMessage(
  id: 'm1',
  threadId: 't1',
  senderId: 'u1',
  kind: ChatMessageKind.text,
  isMine: true,
  timeLabel: '10:00',
);

const _kThread = ChatThread(id: 'thread1');

void main() {
  group('ChatThreadEvent', () {
    group('ChatThreadStarted', () {
      test('stores threadId', () {
        const event = ChatThreadStarted('t1');
        expect(event.threadId, 't1');
      });

      test('props contains threadId', () {
        expect(const ChatThreadStarted('t1').props, ['t1']);
      });

      test('equal when same threadId', () {
        expect(const ChatThreadStarted('t1'), const ChatThreadStarted('t1'));
      });

      test('not equal for different threadId', () {
        expect(
          const ChatThreadStarted('t1'),
          isNot(equals(const ChatThreadStarted('t2'))),
        );
      });
    });

    group('ChatMessagesReceived', () {
      test('stores messages list', () {
        const event = ChatMessagesReceived([_kMessage]);
        expect(event.messages, [_kMessage]);
      });

      test('stores empty list', () {
        expect(const ChatMessagesReceived([]).messages, isEmpty);
      });

      test('props contains messages', () {
        expect(const ChatMessagesReceived([]).props, [[]]);
      });

      test('equal when same messages', () {
        expect(
          const ChatMessagesReceived([_kMessage]),
          const ChatMessagesReceived([_kMessage]),
        );
      });
    });

    group('ChatThreadReceived', () {
      test('stores thread', () {
        const event = ChatThreadReceived(_kThread);
        expect(event.thread, _kThread);
      });

      test('stores null thread', () {
        const event = ChatThreadReceived(null);
        expect(event.thread, isNull);
      });

      test('props contains thread', () {
        expect(const ChatThreadReceived(_kThread).props, [_kThread]);
      });

      test('equal when same thread', () {
        expect(
          const ChatThreadReceived(_kThread),
          const ChatThreadReceived(_kThread),
        );
      });
    });

    group('ChatThreadStreamErrored', () {
      test('stores error', () {
        final error = Exception('oops');
        final event = ChatThreadStreamErrored(error);
        expect(event.error, error);
      });

      test('props contains error', () {
        final error = Exception('oops');
        final event = ChatThreadStreamErrored(error);
        expect(event.props, [error]);
      });

      test('equal when same error instance', () {
        final error = Exception('oops');
        expect(ChatThreadStreamErrored(error), ChatThreadStreamErrored(error));
      });
    });

    group('ChatTextSent', () {
      test('stores text', () {
        const event = ChatTextSent('hello');
        expect(event.text, 'hello');
      });

      test('props contains text', () {
        expect(const ChatTextSent('hi').props, ['hi']);
      });

      test('equal when same text', () {
        expect(const ChatTextSent('hi'), const ChatTextSent('hi'));
      });

      test('not equal for different text', () {
        expect(
          const ChatTextSent('hello'),
          isNot(equals(const ChatTextSent('world'))),
        );
      });
    });

    group('ChatReplySet', () {
      test('stores replyTo message', () {
        const event = ChatReplySet(_kMessage);
        expect(event.replyTo, _kMessage);
      });

      test('stores null replyTo', () {
        const event = ChatReplySet(null);
        expect(event.replyTo, isNull);
      });

      test('props contains replyTo', () {
        expect(const ChatReplySet(_kMessage).props, [_kMessage]);
      });

      test('props with null replyTo', () {
        expect(const ChatReplySet(null).props, [null]);
      });
    });

    group('ChatMediaPicked', () {
      test('stores items list', () {
        final item = ChatOutgoingMedia(
          file: File('/fake/image.jpg'),
          type: MediaType.image,
        );
        final event = ChatMediaPicked([item]);
        expect(event.items, [item]);
      });

      test('props contains items', () {
        final item = ChatOutgoingMedia(
          file: File('/fake/image.jpg'),
          type: MediaType.image,
        );
        final event = ChatMediaPicked([item]);
        expect(event.props, [
          [item],
        ]);
      });

      test('equal when same items instance', () {
        final item = ChatOutgoingMedia(
          file: File('/fake/image.jpg'),
          type: MediaType.image,
        );
        expect(ChatMediaPicked([item]), ChatMediaPicked([item]));
      });
    });

    group('ChatAudioRecorded', () {
      test('stores audio', () {
        final audio = ChatOutgoingMedia(
          file: File('/fake/audio.m4a'),
          type: MediaType.audio,
        );
        final event = ChatAudioRecorded(audio);
        expect(event.audio, audio);
      });

      test('props contains audio', () {
        final audio = ChatOutgoingMedia(
          file: File('/fake/audio.m4a'),
          type: MediaType.audio,
        );
        final event = ChatAudioRecorded(audio);
        expect(event.props, [audio]);
      });
    });

    group('ChatOfferResponded', () {
      test('stores offerId and accept=true', () {
        const event = ChatOfferResponded(offerId: 'offer1', accept: true);
        expect(event.offerId, 'offer1');
        expect(event.accept, isTrue);
      });

      test('stores accept=false', () {
        const event = ChatOfferResponded(offerId: 'offer1', accept: false);
        expect(event.accept, isFalse);
      });

      test('props contains offerId and accept', () {
        expect(
          const ChatOfferResponded(offerId: 'offer1', accept: false).props,
          ['offer1', false],
        );
      });

      test('equal when same values', () {
        expect(
          const ChatOfferResponded(offerId: 'o1', accept: true),
          const ChatOfferResponded(offerId: 'o1', accept: true),
        );
      });

      test('not equal when accept differs', () {
        expect(
          const ChatOfferResponded(offerId: 'o1', accept: true),
          isNot(equals(const ChatOfferResponded(offerId: 'o1', accept: false))),
        );
      });
    });

    group('ChatConversationDeleted', () {
      test('props is empty', () {
        expect(const ChatConversationDeleted().props, isEmpty);
      });

      test('two instances are equal', () {
        expect(
          const ChatConversationDeleted(),
          const ChatConversationDeleted(),
        );
      });
    });

    group('ChatUserBlocked', () {
      test('props is empty', () {
        expect(const ChatUserBlocked().props, isEmpty);
      });

      test('two instances are equal', () {
        expect(const ChatUserBlocked(), const ChatUserBlocked());
      });
    });
  });

  group('ChatThreadState', () {
    group('ChatThreadLoadingState', () {
      test('props is empty', () {
        expect(const ChatThreadLoadingState().props, isEmpty);
      });

      test('two instances are equal', () {
        expect(const ChatThreadLoadingState(), const ChatThreadLoadingState());
      });
    });

    group('ChatThreadErrorState', () {
      test('stores type', () {
        const state = ChatThreadErrorState(type: AppErrorType.network);
        expect(state.type, AppErrorType.network);
      });

      test('props contains type', () {
        expect(const ChatThreadErrorState(type: AppErrorType.server).props, [
          AppErrorType.server,
        ]);
      });

      test('equal when same type', () {
        expect(
          const ChatThreadErrorState(type: AppErrorType.unknown),
          const ChatThreadErrorState(type: AppErrorType.unknown),
        );
      });

      test('not equal for different type', () {
        expect(
          const ChatThreadErrorState(type: AppErrorType.network),
          isNot(equals(const ChatThreadErrorState(type: AppErrorType.timeout))),
        );
      });
    });

    group('ChatThreadLoadedState', () {
      test('default constructor has empty messages and null fields', () {
        const state = ChatThreadLoadedState();
        expect(state.thread, isNull);
        expect(state.messages, isEmpty);
        expect(state.replyTo, isNull);
      });

      test('stores thread, messages, replyTo', () {
        const state = ChatThreadLoadedState(
          thread: _kThread,
          messages: [_kMessage],
          replyTo: _kMessage,
        );
        expect(state.thread, _kThread);
        expect(state.messages, [_kMessage]);
        expect(state.replyTo, _kMessage);
      });

      test('isEmpty returns true when messages empty', () {
        expect(const ChatThreadLoadedState().isEmpty, isTrue);
      });

      test('isEmpty returns false when messages non-empty', () {
        expect(
          const ChatThreadLoadedState(messages: [_kMessage]).isEmpty,
          isFalse,
        );
      });

      test('props contains thread, messages, replyTo', () {
        const state = ChatThreadLoadedState(
          thread: _kThread,
          messages: [_kMessage],
          replyTo: _kMessage,
        );
        expect(state.props, [
          _kThread,
          [_kMessage],
          _kMessage,
        ]);
      });

      test('copyWith updates thread', () {
        const state = ChatThreadLoadedState();
        final updated = state.copyWith(thread: _kThread);
        expect(updated.thread, _kThread);
        expect(updated.messages, isEmpty);
        expect(updated.replyTo, isNull);
      });

      test('copyWith updates messages', () {
        const state = ChatThreadLoadedState();
        final updated = state.copyWith(messages: [_kMessage]);
        expect(updated.messages, [_kMessage]);
      });

      test('copyWith updates replyTo', () {
        const state = ChatThreadLoadedState();
        final updated = state.copyWith(replyTo: _kMessage);
        expect(updated.replyTo, _kMessage);
      });

      test('copyWith clearReply=true sets replyTo to null', () {
        const state = ChatThreadLoadedState(replyTo: _kMessage);
        final updated = state.copyWith(clearReply: true);
        expect(updated.replyTo, isNull);
      });

      test('copyWith clearReply=true takes priority over replyTo argument', () {
        const state = ChatThreadLoadedState(replyTo: _kMessage);
        final updated = state.copyWith(replyTo: _kMessage, clearReply: true);
        expect(updated.replyTo, isNull);
      });

      test('copyWith preserves existing values when nothing passed', () {
        const state = ChatThreadLoadedState(
          thread: _kThread,
          messages: [_kMessage],
          replyTo: _kMessage,
        );
        final updated = state.copyWith();
        expect(updated.thread, _kThread);
        expect(updated.messages, [_kMessage]);
        expect(updated.replyTo, _kMessage);
      });

      test('equal when same fields', () {
        expect(const ChatThreadLoadedState(), const ChatThreadLoadedState());
      });

      test('not equal when messages differ', () {
        expect(
          const ChatThreadLoadedState(),
          isNot(equals(const ChatThreadLoadedState(messages: [_kMessage]))),
        );
      });
    });

    group('ChatThreadClosedState', () {
      test('props is empty', () {
        expect(const ChatThreadClosedState().props, isEmpty);
      });

      test('two instances are equal', () {
        expect(const ChatThreadClosedState(), const ChatThreadClosedState());
      });
    });
  });
}
