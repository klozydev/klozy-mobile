import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/feature/chat/data/response/chat_media_response.dart';
import 'package:klozy/src/feature/chat/data/response/chat_message_response.dart';
import 'package:klozy/src/feature/chat/data/response/chat_offer_response.dart';
import 'package:klozy/src/feature/chat/data/response/chat_purchase_response.dart';
import 'package:klozy/src/feature/chat/data/response/chat_reply_response.dart';
import 'package:klozy/src/feature/chat/data/response/conversation_response.dart';
import 'package:klozy/src/feature/chat/domain/entity/media_type.dart';

/// Firebase-backed chat data source for the purpose-built `chat` collection
/// (denormalized participants + per-user `unreadCounts` for instant, join-free
/// queries). Returns response models; mapping happens in the repo.
@injectable
class ChatRemoteDataSource {
  ChatRemoteDataSource(this._db, this._storage);

  final FirebaseFirestore _db;
  final FirebaseStorage _storage;

  static const String _chat = 'chat';
  static const String _messages = 'messages';

  CollectionReference<Map<String, dynamic>> get _col => _db.collection(_chat);

  CollectionReference<Map<String, dynamic>> _msgCol(String id) =>
      _col.doc(id).collection(_messages);

  /// Deterministic 1:1 conversation id = sorted uids joined by `_`.
  static String conversationId(String a, String b) {
    final List<String> ids = <String>[a, b]..sort();
    return '${ids.first}_${ids[1]}';
  }

  // ── Conversations ──────────────────────────────────────────────────────────

  /// Streams the user's conversations newest-first in a SINGLE query. All
  /// display data is embedded, so the whole list paints in one snapshot.
  Stream<List<ConversationResponse>> watchThreads(String myUid) {
    return _col
        .where('participantIds', arrayContains: myUid)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snap) {
          final List<ConversationResponse> out = <ConversationResponse>[];
          for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
              in snap.docs) {
            final Map<String, dynamic> data = <String, dynamic>{
              ...doc.data(),
              'id': doc.id,
            };
            final List<dynamic> deletedFor =
                (data['deletedFor'] as List<dynamic>?) ?? const <dynamic>[];
            if (deletedFor.contains(myUid)) continue;
            out.add(ConversationResponse.fromJson(data));
          }
          return out;
        });
  }

  /// Streams a single conversation doc (thread header / unread), or null.
  Stream<ConversationResponse?> watchThread(String id) {
    return _col.doc(id).snapshots().map((
      DocumentSnapshot<Map<String, dynamic>> doc,
    ) {
      final Map<String, dynamic>? data = doc.data();
      if (!doc.exists || data == null) return null;
      return ConversationResponse.fromJson(<String, dynamic>{
        ...data,
        'id': doc.id,
      });
    });
  }

  Future<String?> findThread(String myUid, String otherUid) async {
    final String id = conversationId(myUid, otherUid);
    try {
      final DocumentSnapshot<Map<String, dynamic>> snap = await _col
          .doc(id)
          .get();
      return snap.exists ? id : null;
    } catch (_) {
      // A get() on a not-yet-existing conversation evaluates the read rule with
      // a null resource and is denied — treat that as "not found" so the caller
      // creates it (enables messaging any user, not just existing threads).
      return null;
    }
  }

  /// Creates the conversation doc with both denormalized participant profiles.
  Future<String> createThread(
    String myUid,
    String otherUid, {
    required Map<String, dynamic> participants,
  }) async {
    final String id = conversationId(myUid, otherUid);
    await _col.doc(id).set(<String, dynamic>{
      'id': id,
      'participantIds': <String>[myUid, otherUid],
      'participants': participants,
      'unreadCounts': <String, int>{myUid: 0, otherUid: 0},
      'blockedBy': <String>[],
      'deletedFor': <String>[],
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessageAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return id;
  }

  /// Refreshes the embedded participant profiles (best-effort).
  Future<void> embedParticipants(
    String id,
    Map<String, dynamic> participants,
  ) async {
    if (participants.isEmpty) return;
    try {
      await _col.doc(id).set(<String, dynamic>{
        'participants': participants,
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  // ── Messages ────────────────────────────────────────────────────────────────

  Stream<List<ChatMessageResponse>> watchMessages(String id) {
    return _msgCol(id).orderBy('createdAt').snapshots().map((
      QuerySnapshot<Map<String, dynamic>> snap,
    ) {
      return snap.docs
          .map(
            (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                ChatMessageResponse.fromJson(<String, dynamic>{
                  ...doc.data(),
                  'id': doc.id,
                }),
          )
          .toList();
    });
  }

  /// Writes a message and updates the conversation's denormalized preview +
  /// recipients' unread counters in one batch.
  Future<void> sendMessage(
    String id, {
    required String senderId,
    required String type,
    required String clientId,
    String? text,
    List<ChatMediaResponse>? media,
    ChatReplyResponse? replyTo,
    ChatOfferResponse? offer,
    ChatPurchaseResponse? purchase,
  }) async {
    final DocumentReference<Map<String, dynamic>> convRef = _col.doc(id);
    final DocumentReference<Map<String, dynamic>> msgRef = _msgCol(id).doc();

    final ChatMessageResponse model = ChatMessageResponse(
      id: msgRef.id,
      conversationId: id,
      senderId: senderId,
      type: type,
      text: text,
      media: media,
      replyTo: replyTo,
      offer: offer,
      purchase: purchase,
      readBy: <String>[senderId],
      clientId: clientId,
    );
    final Map<String, dynamic> json = model.toJson()
      ..['createdAt'] = FieldValue.serverTimestamp();

    // Recipients = the other participant(s). Read the real participantIds from
    // the (already-created) conversation doc — ids can contain `_` (seed users),
    // so the conversation id can't be split reliably. The optimistic UI hides
    // this read's latency.
    final DocumentSnapshot<Map<String, dynamic>> convSnap = await convRef.get();
    final List<String> participantIds =
        ((convSnap.data()?['participantIds'] as List<dynamic>?) ??
                const <dynamic>[])
            .cast<String>();

    final Map<String, dynamic> convUpdate = <String, dynamic>{
      'lastMessage': <String, dynamic>{
        'text': type == 'text' ? text : null,
        'type': type,
        'senderId': senderId,
      },
      'lastMessageAt': FieldValue.serverTimestamp(),
      'deletedFor': <String>[],
    };
    for (final String uid in participantIds) {
      if (uid != senderId) {
        convUpdate['unreadCounts.$uid'] = FieldValue.increment(1);
      }
    }

    final WriteBatch batch = _db.batch();
    batch.set(msgRef, json);
    batch.set(convRef, convUpdate, SetOptions(merge: true));
    await batch.commit();
  }

  Future<void> markThreadSeen(String id, String myUid) async {
    try {
      await _col.doc(id).set(<String, dynamic>{
        'unreadCounts': <String, dynamic>{myUid: 0},
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<void> deleteConversation(String id, String myUid) async {
    await _col.doc(id).update(<String, dynamic>{
      'deletedFor': FieldValue.arrayUnion(<String>[myUid]),
    });
  }

  Future<void> blockUser(String id, String myUid) async {
    await _col.doc(id).update(<String, dynamic>{
      'blockedBy': FieldValue.arrayUnion(<String>[myUid]),
    });
  }

  // ── Media upload ─────────────────────────────────────────────────────────────

  Future<ChatMediaResponse> uploadFile(
    String conversationId,
    File file,
    MediaType type, {
    String? name,
    int? durationMs,
  }) async {
    final String ext = file.path.contains('.')
        ? file.path.split('.').last
        : 'bin';
    final String mediaId = _msgCol(conversationId).doc().id;
    final String path = 'chat_media/$conversationId/$mediaId.$ext';

    final Reference ref = _storage.ref(path);
    await ref.putFile(file);
    final String url = await ref.getDownloadURL();

    return ChatMediaResponse(
      id: mediaId,
      url: url,
      type: type.raw,
      name: name ?? file.path.split('/').last,
      durationMs: durationMs,
      relativePath: path,
    );
  }
}
