import 'package:klozy/src/feature/chat/domain/entity/chat_message.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_outgoing_media.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_thread.dart';

/// Chat domain boundary. All Firebase / REST details live in the impl.
abstract class ChatRepository {
  /// The current user's Firebase UID, or null if signed out.
  String? get currentUserId;

  /// Live list of the current user's 1:1 threads, newest first.
  Stream<List<ChatThread>> watchThreads();

  /// Live messages for [threadId], oldest first.
  Stream<List<ChatMessage>> watchMessages(String threadId);

  /// Live single thread (for the thread header), or null if it doesn't exist.
  Stream<ChatThread?> watchThread(String threadId);

  /// Resolves (or creates) the 1:1 conversation with [otherUserId] (a backend
  /// user id) and embeds participant display data ([displayName] / [avatarUrl]
  /// hints from the caller). Returns the conversation id.
  Future<String?> openOrCreateThread(
    String otherUserId, {
    String? displayName,
    String? avatarUrl,
  });

  Future<void> sendText(
    String threadId,
    String text, {
    required String clientId,
    ChatMessage? replyTo,
  });

  /// Uploads then sends a media message. [clientId] correlates it to the
  /// optimistic bubble already on screen.
  Future<void> sendMedia(
    String threadId,
    ChatOutgoingMedia item, {
    required String clientId,
  });

  /// Uploads then sends a recorded voice message.
  Future<void> sendAudio(
    String threadId,
    ChatOutgoingMedia audio, {
    required String clientId,
  });

  Future<void> markSeen(String threadId);

  Future<void> deleteConversation(String threadId);

  Future<void> reportAndBlock(String threadId, String otherUserId);

  /// Accept / refuse an incoming offer via the backend (`/v1/offers/{id}`).
  Future<void> respondToOffer(String offerId, {required bool accept});
}
