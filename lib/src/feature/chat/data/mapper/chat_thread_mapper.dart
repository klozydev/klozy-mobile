import 'package:klozy/src/feature/chat/data/mapper/chat_time_formatter.dart';
import 'package:klozy/src/feature/chat/data/response/chat_participant_response.dart';
import 'package:klozy/src/feature/chat/data/response/conversation_response.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_participant.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_thread.dart';

/// Maps a Firestore conversation doc into the render-ready [ChatThread],
/// resolving the other participant and the unread count against the current
/// user — all from the single doc the list query already streamed.
abstract final class ChatThreadMapper {
  static ChatThread toEntity(
    ConversationResponse r, {
    required String myUid,
    String? myBackendId,
    DateTime? now,
  }) {
    final List<String> participantIds = r.participantIds ?? const <String>[];
    final String otherId = participantIds.firstWhere(
      (String p) => p != myUid && p != myBackendId,
      orElse: () => '',
    );

    final ChatParticipantResponse? p = r.participants?[otherId];
    final ChatParticipant other = p == null
        ? ChatParticipant(id: otherId)
        : ChatParticipant(
            id: otherId,
            displayName: p.displayName ?? '',
            avatarUrl: (p.avatarUrl?.isEmpty ?? true) ? null : p.avatarUrl,
            rating: p.rating?.toDouble() ?? 0,
            isPro: p.isPro ?? false,
          );

    return ChatThread(
      id: r.id ?? '',
      participants: participantIds,
      other: other,
      hasLastMessage: r.lastMessage != null,
      lastMessageType: r.lastMessage?.type,
      lastMessageText: r.lastMessage?.text,
      lastMessageFromMe: _isMine(r.lastMessage?.senderId, myUid, myBackendId),
      lastMessageAt: r.lastMessageAt,
      timeLabel: ChatTimeFormatter.label(r.lastMessageAt, now: now),
      unreadCount: r.unreadCounts?[myUid] ?? 0,
      blockedBy: r.blockedBy ?? const <String>[],
    );
  }

  static bool _isMine(String? senderId, String myUid, String? myBackendId) {
    if (senderId == null || senderId.isEmpty) return false;
    return senderId == myUid ||
        (myBackendId != null && senderId == myBackendId);
  }
}
