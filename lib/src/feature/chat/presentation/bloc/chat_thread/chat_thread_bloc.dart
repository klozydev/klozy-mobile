import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_media.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_message.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_outgoing_media.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_thread.dart';
import 'package:klozy/src/feature/chat/domain/entity/media_type.dart';
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
import 'package:klozy/src/feature/chat/presentation/bloc/chat_thread/chat_thread_event.dart';
import 'package:klozy/src/feature/chat/presentation/bloc/chat_thread/chat_thread_state.dart';

@injectable
class ChatThreadBloc extends Bloc<ChatThreadEvent, ChatThreadState> {
  ChatThreadBloc(
    this._watchMessages,
    this._watchThread,
    this._sendText,
    this._sendMedia,
    this._sendAudio,
    this._markSeen,
    this._deleteConversation,
    this._reportAndBlock,
    this._respondToOffer,
  ) : super(const ChatThreadLoadingState()) {
    on<ChatThreadStarted>(_onStarted);
    on<ChatMessagesReceived>(_onMessages);
    on<ChatThreadReceived>(_onThread);
    on<ChatThreadStreamErrored>(_onErrored);
    on<ChatTextSent>(_onTextSent);
    on<ChatReplySet>(_onReplySet);
    on<ChatMediaPicked>(_onMediaPicked);
    on<ChatAudioRecorded>(_onAudioRecorded);
    on<ChatOfferResponded>(_onOfferResponded);
    on<ChatConversationDeleted>(_onConversationDeleted);
    on<ChatUserBlocked>(_onUserBlocked);
  }

  final WatchMessages _watchMessages;
  final WatchThread _watchThread;
  final SendTextMessage _sendText;
  final SendMediaMessage _sendMedia;
  final SendAudioMessage _sendAudio;
  final MarkThreadSeen _markSeen;
  final DeleteConversation _deleteConversation;
  final ReportAndBlock _reportAndBlock;
  final RespondToOffer _respondToOffer;

  String _threadId = '';
  int _seq = 0;
  List<ChatMessage> _stream = <ChatMessage>[];
  final List<ChatMessage> _pending = <ChatMessage>[];
  StreamSubscription<List<ChatMessage>>? _messagesSub;
  StreamSubscription<ChatThread?>? _threadSub;

  void _onStarted(ChatThreadStarted event, Emitter<ChatThreadState> emit) {
    _threadId = event.threadId;
    emit(const ChatThreadLoadedState());

    FirebaseAuth.instance.currentUser?.getIdTokenResult().then(
      (IdTokenResult r) => debugPrint(
        'CHAT CLAIMS: klozyUserId=${r.claims?['klozyUserId']} all=${r.claims}',
      ),
    );

    _messagesSub?.cancel();
    _messagesSub = _watchMessages(_threadId).listen(
      (List<ChatMessage> m) => add(ChatMessagesReceived(m)),
      onError: (Object e) => add(ChatThreadStreamErrored(e)),
    );

    _threadSub?.cancel();
    _threadSub = _watchThread(_threadId).listen(
      (ChatThread? t) => add(ChatThreadReceived(t)),
      onError: (Object e) => add(ChatThreadStreamErrored(e)),
    );

    _markSeen(_threadId);
  }

  void _onMessages(ChatMessagesReceived event, Emitter<ChatThreadState> emit) {
    _stream = event.messages;
    // Drop optimistic bubbles the server has now echoed back (matched by id).
    final Set<String> delivered = _stream
        .map((ChatMessage m) => m.clientId)
        .whereType<String>()
        .toSet();
    _pending.removeWhere(
      (ChatMessage p) => p.clientId != null && delivered.contains(p.clientId),
    );
    emit(_loaded.copyWith(messages: _merged()));
    _markSeen(_threadId);
  }

  void _onThread(ChatThreadReceived event, Emitter<ChatThreadState> emit) {
    emit(_loaded.copyWith(thread: event.thread));
  }

  void _onErrored(
    ChatThreadStreamErrored event,
    Emitter<ChatThreadState> emit,
  ) {
    if (state is! ChatThreadLoadedState) {
      emit(ChatThreadErrorState(type: AppErrorType.fromException(event.error)));
    }
  }

  Future<void> _onTextSent(
    ChatTextSent event,
    Emitter<ChatThreadState> emit,
  ) async {
    final String text = event.text.trim();
    if (text.isEmpty) return;
    final ChatMessage? replyTo = _loaded.replyTo;
    final String clientId = _nextClientId();

    _pending.add(
      _optimistic(
        clientId: clientId,
        kind: ChatMessageKind.text,
        text: text,
        replyTo: replyTo,
      ),
    );
    emit(_loaded.copyWith(messages: _merged(), clearReply: true));

    try {
      await _sendText(_threadId, text, clientId: clientId, replyTo: replyTo);
    } catch (e, st) {
      debugPrint('CHAT SEND FAILED (text): $e\n$st');
      _markFailed(clientId);
      emit(_loaded.copyWith(messages: _merged()));
    }
  }

  void _onReplySet(ChatReplySet event, Emitter<ChatThreadState> emit) {
    emit(
      event.replyTo == null
          ? _loaded.copyWith(clearReply: true)
          : _loaded.copyWith(replyTo: event.replyTo),
    );
  }

  Future<void> _onMediaPicked(
    ChatMediaPicked event,
    Emitter<ChatThreadState> emit,
  ) async {
    for (final ChatOutgoingMedia item in event.items) {
      final String clientId = _nextClientId();
      _pending.add(
        _optimistic(
          clientId: clientId,
          kind: _kindOf(item.type),
          media: <ChatMedia>[
            ChatMedia(
              localPath: item.file.path,
              type: item.type,
              name: item.name,
              durationMs: item.durationMs,
            ),
          ],
        ),
      );
      emit(_loaded.copyWith(messages: _merged()));
      try {
        await _sendMedia(_threadId, item, clientId: clientId);
      } catch (e, st) {
        debugPrint('CHAT SEND FAILED (media): $e\n$st');
        _markFailed(clientId);
        emit(_loaded.copyWith(messages: _merged()));
      }
    }
  }

  Future<void> _onAudioRecorded(
    ChatAudioRecorded event,
    Emitter<ChatThreadState> emit,
  ) async {
    final String clientId = _nextClientId();
    _pending.add(
      _optimistic(
        clientId: clientId,
        kind: ChatMessageKind.audio,
        media: <ChatMedia>[
          ChatMedia(
            localPath: event.audio.file.path,
            type: MediaType.audio,
            name: event.audio.name,
            durationMs: event.audio.durationMs,
          ),
        ],
      ),
    );
    emit(_loaded.copyWith(messages: _merged()));
    try {
      await _sendAudio(_threadId, event.audio, clientId: clientId);
    } catch (e, st) {
      debugPrint('CHAT SEND FAILED (audio): $e\n$st');
      _markFailed(clientId);
      emit(_loaded.copyWith(messages: _merged()));
    }
  }

  Future<void> _onOfferResponded(
    ChatOfferResponded event,
    Emitter<ChatThreadState> emit,
  ) async {
    try {
      await _respondToOffer(event.offerId, accept: event.accept);
    } catch (_) {}
  }

  Future<void> _onConversationDeleted(
    ChatConversationDeleted event,
    Emitter<ChatThreadState> emit,
  ) async {
    try {
      await _deleteConversation(_threadId);
    } catch (_) {}
    emit(const ChatThreadClosedState());
  }

  Future<void> _onUserBlocked(
    ChatUserBlocked event,
    Emitter<ChatThreadState> emit,
  ) async {
    final String otherId = _loaded.thread?.other.id ?? '';
    try {
      await _reportAndBlock(_threadId, otherId);
    } catch (_) {}
    emit(const ChatThreadClosedState());
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  /// Stream messages followed by still-pending optimistic bubbles (newest last).
  List<ChatMessage> _merged() => <ChatMessage>[..._stream, ..._pending];

  ChatMessage _optimistic({
    required String clientId,
    required ChatMessageKind kind,
    String? text,
    List<ChatMedia> media = const <ChatMedia>[],
    ChatMessage? replyTo,
  }) {
    return ChatMessage(
      id: clientId,
      threadId: _threadId,
      senderId: '',
      kind: kind,
      isMine: true,
      text: text,
      media: media,
      replyTo: replyTo,
      sendStatus: 'sending',
      clientId: clientId,
      timeLabel: 'now',
    );
  }

  void _markFailed(String clientId) {
    final int i = _pending.indexWhere(
      (ChatMessage m) => m.clientId == clientId,
    );
    if (i != -1) _pending[i] = _pending[i].copyWith(sendStatus: 'failed');
  }

  ChatMessageKind _kindOf(MediaType type) {
    switch (type) {
      case MediaType.image:
        return ChatMessageKind.image;
      case MediaType.video:
        return ChatMessageKind.video;
      case MediaType.audio:
        return ChatMessageKind.audio;
      case MediaType.other:
        return ChatMessageKind.file;
    }
  }

  String _nextClientId() =>
      '$_threadId-${_seq++}-${DateTime.now().microsecondsSinceEpoch}';

  ChatThreadLoadedState get _loaded => state is ChatThreadLoadedState
      ? state as ChatThreadLoadedState
      : const ChatThreadLoadedState();

  @override
  Future<void> close() {
    _messagesSub?.cancel();
    _threadSub?.cancel();
    return super.close();
  }
}
