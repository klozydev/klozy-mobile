/// Tests for ChatThreadBloc.
///
/// SKIPPED: [ChatThreadStarted] — _onStarted calls
/// `FirebaseAuth.instance.currentUser` which is a static Firebase SDK access
/// that cannot be mocked in unit tests without full Firebase plugin
/// initialization. All other events are testable because the `_loaded` getter
/// returns `const ChatThreadLoadedState()` as fallback when state is still
/// ChatThreadLoadingState.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_message.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_thread.dart';
import 'package:klozy/src/feature/chat/domain/entity/message_kind.dart';
import 'package:klozy/src/feature/chat/domain/usecase/delete_conversation.dart';
import 'package:klozy/src/feature/chat/domain/usecase/mark_thread_seen.dart';
import 'package:klozy/src/feature/chat/domain/usecase/report_and_block.dart';
import 'package:klozy/src/feature/chat/domain/usecase/respond_to_offer.dart';
import 'package:klozy/src/feature/chat/domain/usecase/send_audio_message.dart';
import 'package:klozy/src/feature/chat/domain/usecase/send_media_message.dart';
import 'package:klozy/src/feature/chat/domain/usecase/send_text_message.dart';
import 'package:klozy/src/feature/chat/domain/usecase/watch_messages.dart';
import 'package:klozy/src/feature/chat/domain/usecase/watch_thread.dart';
import 'package:klozy/src/feature/chat/presentation/bloc/chat_thread/chat_thread_bloc.dart';
import 'package:klozy/src/feature/chat/presentation/bloc/chat_thread/chat_thread_event.dart';
import 'package:klozy/src/feature/chat/presentation/bloc/chat_thread/chat_thread_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockWatchMessages extends Mock implements WatchMessages {}

class _MockWatchThread extends Mock implements WatchThread {}

class _MockSendTextMessage extends Mock implements SendTextMessage {}

class _MockSendMediaMessage extends Mock implements SendMediaMessage {}

class _MockSendAudioMessage extends Mock implements SendAudioMessage {}

class _MockMarkThreadSeen extends Mock implements MarkThreadSeen {}

class _MockDeleteConversation extends Mock implements DeleteConversation {}

class _MockReportAndBlock extends Mock implements ReportAndBlock {}

class _MockRespondToOffer extends Mock implements RespondToOffer {}

Future<List<ChatThreadState>> _collectStates(
  ChatThreadBloc bloc,
  ChatThreadEvent event,
) async {
  final states = <ChatThreadState>[];
  final sub = bloc.stream.listen(states.add);
  bloc.add(event);
  await Future<void>.delayed(Duration.zero);
  await sub.cancel();
  return states;
}

const _kMessage = ChatMessage(
  id: 'm1',
  threadId: 't1',
  senderId: 'u2',
  kind: ChatMessageKind.text,
  isMine: false,
  text: 'Hello',
  timeLabel: '10:00',
);
const _kThread = ChatThread(id: 't1');

ChatThreadBloc _makeBloc({
  _MockWatchMessages? watch,
  _MockWatchThread? watchThread,
  _MockSendTextMessage? sendText,
  _MockSendMediaMessage? sendMedia,
  _MockSendAudioMessage? sendAudio,
  _MockMarkThreadSeen? markSeen,
  _MockDeleteConversation? deleteConv,
  _MockReportAndBlock? reportBlock,
  _MockRespondToOffer? respond,
}) {
  return ChatThreadBloc(
    watch ?? _MockWatchMessages(),
    watchThread ?? _MockWatchThread(),
    sendText ?? _MockSendTextMessage(),
    sendMedia ?? _MockSendMediaMessage(),
    sendAudio ?? _MockSendAudioMessage(),
    markSeen ?? _MockMarkThreadSeen(),
    deleteConv ?? _MockDeleteConversation(),
    reportBlock ?? _MockReportAndBlock(),
    respond ?? _MockRespondToOffer(),
  );
}

void main() {
  late _MockWatchMessages mockWatch;
  late _MockWatchThread mockWatchThread;
  late _MockSendTextMessage mockSendText;
  late _MockMarkThreadSeen mockMarkSeen;
  late _MockDeleteConversation mockDeleteConv;
  late _MockReportAndBlock mockReportBlock;
  late _MockRespondToOffer mockRespond;
  late ChatThreadBloc bloc;

  setUp(() {
    mockWatch = _MockWatchMessages();
    mockWatchThread = _MockWatchThread();
    mockSendText = _MockSendTextMessage();
    mockMarkSeen = _MockMarkThreadSeen();
    mockDeleteConv = _MockDeleteConversation();
    mockReportBlock = _MockReportAndBlock();
    mockRespond = _MockRespondToOffer();
    bloc = _makeBloc(
      watch: mockWatch,
      watchThread: mockWatchThread,
      sendText: mockSendText,
      markSeen: mockMarkSeen,
      deleteConv: mockDeleteConv,
      reportBlock: mockReportBlock,
      respond: mockRespond,
    );
  });

  tearDown(() => bloc.close());

  // ChatThreadStarted is SKIPPED — calls FirebaseAuth.instance.currentUser
  // (static access) which cannot be mocked in pure unit tests.

  test('initial state is ChatThreadLoadingState', () {
    expect(bloc.state, const ChatThreadLoadingState());
  });

  group('ChatMessagesReceived (internal)', () {
    test('emits loaded state with received messages', () async {
      when(() => mockMarkSeen.call(any())).thenAnswer((_) async {});

      final states = await _collectStates(
        bloc,
        const ChatMessagesReceived(<ChatMessage>[_kMessage]),
      );

      final loaded = states.last as ChatThreadLoadedState;
      expect(loaded.messages, [_kMessage]);
    });
  });

  group('ChatThreadReceived (internal)', () {
    test('emits loaded state with thread', () async {
      final states = await _collectStates(
        bloc,
        const ChatThreadReceived(_kThread),
      );

      final loaded = states.last as ChatThreadLoadedState;
      expect(loaded.thread, _kThread);
    });
  });

  group('ChatThreadStreamErrored (internal)', () {
    test('emits error when state is loading', () async {
      // State is ChatThreadLoadingState (initial)
      final states = await _collectStates(
        bloc,
        ChatThreadStreamErrored(Exception('firestore')),
      );

      expect(states.last, isA<ChatThreadErrorState>());
    });

    test('does not emit error when already loaded', () async {
      when(() => mockMarkSeen.call(any())).thenAnswer((_) async {});
      // First get into loaded state
      final sub = bloc.stream.listen((_) {});
      bloc.add(const ChatMessagesReceived(<ChatMessage>[]));
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      final states = await _collectStates(
        bloc,
        ChatThreadStreamErrored(Exception('transient')),
      );

      // Error is suppressed when already loaded
      expect(states.every((s) => s is! ChatThreadErrorState), isTrue);
    });
  });

  group('ChatTextSent', () {
    test('optimistically adds message and sends via usecase', () async {
      when(
        () => mockSendText.call(
          any(),
          any(),
          clientId: any(named: 'clientId'),
          replyTo: any(named: 'replyTo'),
        ),
      ).thenAnswer((_) async {});

      final states = await _collectStates(
        bloc,
        const ChatTextSent('Hello world'),
      );

      // First state has optimistic message
      final loaded = states.first as ChatThreadLoadedState;
      expect(loaded.messages, isNotEmpty);
      expect(loaded.messages.first.text, 'Hello world');
      expect(loaded.messages.first.sendStatus, 'sending');
      verify(
        () => mockSendText.call(
          any(),
          'Hello world',
          clientId: any(named: 'clientId'),
          replyTo: any(named: 'replyTo'),
        ),
      ).called(1);
    });

    test('marks message as failed when send throws', () async {
      when(
        () => mockSendText.call(
          any(),
          any(),
          clientId: any(named: 'clientId'),
          replyTo: any(named: 'replyTo'),
        ),
      ).thenThrow(Exception('network'));

      final states = await _collectStates(
        bloc,
        const ChatTextSent('Hello world'),
      );

      // Last state has failed message
      final last = states.last as ChatThreadLoadedState;
      expect(last.messages.first.sendStatus, 'failed');
    });

    test('does nothing when text is empty or whitespace', () async {
      final states = await _collectStates(bloc, const ChatTextSent('   '));
      expect(states, isEmpty);
    });
  });

  group('ChatReplySet', () {
    test('sets replyTo when message provided', () async {
      final states = await _collectStates(bloc, const ChatReplySet(_kMessage));

      final loaded = states.last as ChatThreadLoadedState;
      expect(loaded.replyTo, _kMessage);
    });

    test('clears replyTo when null provided', () async {
      // First set a reply
      final sub = bloc.stream.listen((_) {});
      bloc.add(const ChatReplySet(_kMessage));
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      final states = await _collectStates(bloc, const ChatReplySet(null));

      final loaded = states.last as ChatThreadLoadedState;
      expect(loaded.replyTo, isNull);
    });
  });

  group('ChatOfferResponded', () {
    test('calls respondToOffer (fire-and-forget)', () async {
      when(
        () => mockRespond.call(any(), accept: any(named: 'accept')),
      ).thenAnswer((_) async {});

      bloc.add(const ChatOfferResponded(offerId: 'offer1', accept: true));
      await Future<void>.delayed(Duration.zero);

      verify(() => mockRespond.call('offer1', accept: true)).called(1);
    });

    test('silently swallows error', () async {
      when(
        () => mockRespond.call(any(), accept: any(named: 'accept')),
      ).thenThrow(Exception('server'));

      bloc.add(const ChatOfferResponded(offerId: 'offer1', accept: false));
      await Future<void>.delayed(Duration.zero);
      // No exception thrown, no error state
    });
  });

  group('ChatConversationDeleted', () {
    test('calls deleteConversation and emits ChatThreadClosedState', () async {
      when(() => mockDeleteConv.call(any())).thenAnswer((_) async {});

      final states = await _collectStates(
        bloc,
        const ChatConversationDeleted(),
      );

      expect(states.last, const ChatThreadClosedState());
      verify(() => mockDeleteConv.call(any())).called(1);
    });

    test('still emits closed even when deleteConversation throws', () async {
      when(() => mockDeleteConv.call(any())).thenThrow(Exception('server'));

      final states = await _collectStates(
        bloc,
        const ChatConversationDeleted(),
      );

      expect(states.last, const ChatThreadClosedState());
    });
  });

  group('ChatUserBlocked', () {
    test('calls reportAndBlock and emits ChatThreadClosedState', () async {
      when(() => mockReportBlock.call(any(), any())).thenAnswer((_) async {});

      final states = await _collectStates(bloc, const ChatUserBlocked());

      expect(states.last, const ChatThreadClosedState());
      verify(() => mockReportBlock.call(any(), any())).called(1);
    });

    test('still emits closed even when reportAndBlock throws', () async {
      when(
        () => mockReportBlock.call(any(), any()),
      ).thenThrow(Exception('server'));

      final states = await _collectStates(bloc, const ChatUserBlocked());

      expect(states.last, const ChatThreadClosedState());
    });
  });
}
