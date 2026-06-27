import 'package:event_bus/event_bus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/core/events/profile_changed_event.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/me/entity/me_profile.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:klozy/src/domain/offers/offers_repository.dart';
import 'package:klozy/src/feature/chat/data/datasource/chat_remote_data_source.dart';
import 'package:klozy/src/feature/chat/data/mapper/chat_message_mapper.dart';
import 'package:klozy/src/feature/chat/data/mapper/chat_thread_mapper.dart';
import 'package:klozy/src/feature/chat/data/response/chat_media_response.dart';
import 'package:klozy/src/feature/chat/data/response/chat_message_response.dart';
import 'package:klozy/src/feature/chat/data/response/chat_reply_response.dart';
import 'package:klozy/src/feature/chat/data/response/conversation_response.dart';
import 'package:klozy/src/feature/chat/domain/chat_repository.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_message.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_outgoing_media.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_thread.dart';
import 'package:klozy/src/feature/chat/domain/entity/message_kind.dart';

/// Conversations are keyed by **backend user ids** — every "message this user"
/// caller already has the other user's backend id, so no id resolution (and no
/// REST call) is needed inside chat. My own id + display come from the cached
/// [MeRepository.getMe] (warmed at app start → no network), the other user's
/// display comes from the caller's hints (embedded into the conversation doc).
/// All reads/writes are Firebase-only.
@Injectable(as: ChatRepository)
class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this._remote, this._auth, this._me, this._offers) {
    // Drop the cached name/avatar when the user edits their profile so the next
    // conversation write embeds fresh participant data. Also re-arm the one-shot
    // token refresh: completing onboarding is when the backend grants the
    // `klozyUserId` claim, so the next _ensureMe must force a fresh ID token to
    // carry that claim to the Firestore rules (otherwise chat stays denied until
    // a cold start mints a new token).
    locator<EventBus>().on<ProfileChangedEvent>().listen((_) {
      _meLoaded = false;
      _myId = null;
      _myName = null;
      _myAvatar = null;
      _claimRefreshed = false;
    });
  }

  final ChatRemoteDataSource _remote;
  final FirebaseAuth _auth;
  final MeRepository _me;
  final OffersRepository _offers;

  String? _myId;
  String? _myName;
  String? _myAvatar;
  bool _meLoaded = false;

  /// The Firebase ID token is refreshed once per app session so the backend's
  /// `klozyUserId` custom claim (set on provisioning) reaches the token the
  /// Firestore rules read.
  static bool _claimRefreshed = false;

  @override
  String? get currentUserId => _myId;

  /// Resolves my backend id + display from the cached profile (no network when
  /// the cache is warm, which it is after account bootstrap).
  Future<String?> _ensureMe() async {
    if (_meLoaded) return _myId;
    if (_auth.currentUser == null) return null;
    try {
      // Triggers provisioning (which sets the klozyUserId claim on first call).
      final MeProfile me = await _me.getMe();
      _myId = me.id;
      _myName = '${me.firstName ?? ''} ${me.lastName ?? ''}'.trim();
      _myAvatar = me.avatarUrl;
      _meLoaded = true;
      if (!_claimRefreshed) {
        _claimRefreshed = true;
        await _auth.currentUser?.getIdToken(true);
      }
    } catch (_) {}
    return _myId;
  }

  @override
  Stream<List<ChatThread>> watchThreads() async* {
    final String? myId = await _ensureMe();
    if (myId == null) return;
    yield* _remote
        .watchThreads(myId)
        .map(
          (List<ConversationResponse> rows) => rows
              .map(
                (ConversationResponse r) => ChatThreadMapper.toEntity(
                  r,
                  myUid: myId,
                  myBackendId: _auth.currentUser?.uid,
                ),
              )
              .toList(),
        );
  }

  @override
  Stream<List<ChatMessage>> watchMessages(String threadId) async* {
    final String? myId = await _ensureMe();
    if (myId == null) return;
    yield* _remote
        .watchMessages(threadId)
        .map(
          (List<ChatMessageResponse> rows) => rows
              .map(
                (ChatMessageResponse r) => ChatMessageMapper.toEntity(
                  r,
                  myUid: myId,
                  myBackendId: _auth.currentUser?.uid,
                ),
              )
              .toList(),
        );
  }

  @override
  Stream<ChatThread?> watchThread(String threadId) async* {
    final String? myId = await _ensureMe();
    if (myId == null) return;
    yield* _remote
        .watchThread(threadId)
        .map(
          (r) => r == null
              ? null
              : ChatThreadMapper.toEntity(
                  r,
                  myUid: myId,
                  myBackendId: _auth.currentUser?.uid,
                ),
        );
  }

  @override
  Future<String?> openOrCreateThread(
    String otherUserId, {
    String? displayName,
    String? avatarUrl,
  }) async {
    final String? myId = await _ensureMe();
    if (myId == null || otherUserId.isEmpty || otherUserId == myId) return null;

    final Map<String, dynamic> participants = <String, dynamic>{
      myId: _participant(myId, _myName, _myAvatar),
      otherUserId: _participant(otherUserId, displayName, avatarUrl),
    };

    final String? existing = await _remote.findThread(myId, otherUserId);
    if (existing != null) {
      await _remote.embedParticipants(existing, participants);
      return existing;
    }
    return _remote.createThread(myId, otherUserId, participants: participants);
  }

  Map<String, dynamic> _participant(String id, String? name, String? avatar) {
    return <String, dynamic>{
      'userId': id,
      'displayName': name ?? '',
      'avatarUrl': avatar,
      'rating': 0,
      'isPro': false,
    };
  }

  @override
  Future<void> sendText(
    String threadId,
    String text, {
    required String clientId,
    ChatMessage? replyTo,
  }) async {
    final String? myId = await _ensureMe();
    if (myId == null) return;
    await _remote.sendMessage(
      threadId,
      senderId: myId,
      type: 'text',
      clientId: clientId,
      text: text,
      replyTo: _reply(replyTo),
    );
  }

  @override
  Future<void> sendMedia(
    String threadId,
    ChatOutgoingMedia item, {
    required String clientId,
  }) async {
    final String? myId = await _ensureMe();
    if (myId == null) return;
    final ChatMediaResponse media = await _remote.uploadFile(
      threadId,
      item.file,
      item.type,
      name: item.name,
      durationMs: item.durationMs,
    );
    await _remote.sendMessage(
      threadId,
      senderId: myId,
      type: 'media',
      clientId: clientId,
      media: <ChatMediaResponse>[media],
    );
  }

  @override
  Future<void> sendAudio(
    String threadId,
    ChatOutgoingMedia audio, {
    required String clientId,
  }) async {
    final String? myId = await _ensureMe();
    if (myId == null) return;
    final ChatMediaResponse media = await _remote.uploadFile(
      threadId,
      audio.file,
      audio.type,
      name: audio.name,
      durationMs: audio.durationMs,
    );
    await _remote.sendMessage(
      threadId,
      senderId: myId,
      type: 'audio',
      clientId: clientId,
      media: <ChatMediaResponse>[media],
    );
  }

  @override
  Future<void> markSeen(String threadId) async {
    final String? myId = await _ensureMe();
    if (myId == null) return;
    await _remote.markThreadSeen(threadId, myId);
  }

  @override
  Future<void> deleteConversation(String threadId) async {
    final String? myId = await _ensureMe();
    if (myId == null) return;
    await _remote.deleteConversation(threadId, myId);
  }

  @override
  Future<void> reportAndBlock(String threadId, String otherUserId) async {
    final String? myId = await _ensureMe();
    if (myId == null) return;
    await _remote.blockUser(threadId, myId);
  }

  @override
  Future<void> respondToOffer(String offerId, {required bool accept}) async {
    if (offerId.isEmpty) return;
    if (accept) {
      await _offers.acceptOffer(offerId);
    } else {
      await _offers.declineOffer(offerId);
    }
  }

  ChatReplyResponse? _reply(ChatMessage? m) {
    if (m == null) return null;
    return ChatReplyResponse(
      id: m.id,
      senderId: m.senderId,
      type: _rawType(m.kind),
      text: m.text,
    );
  }

  String _rawType(ChatMessageKind kind) {
    switch (kind) {
      case ChatMessageKind.text:
        return 'text';
      case ChatMessageKind.image:
      case ChatMessageKind.video:
      case ChatMessageKind.file:
        return 'media';
      case ChatMessageKind.audio:
        return 'audio';
      case ChatMessageKind.offer:
        return 'offer';
      case ChatMessageKind.purchase:
        return 'purchase';
      case ChatMessageKind.event:
      case ChatMessageKind.deleted:
        return 'event';
    }
  }
}
