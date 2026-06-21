import 'package:equatable/equatable.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_participant.dart';

/// A 1:1 conversation. Maps to a `chat/{id}` doc.
///
/// [other] and [unreadCount] are derived in the mapper against the current
/// user. The last-message fields are kept raw so the list row can build a
/// localized preview line itself (no English baked into the data layer).
class ChatThread extends Equatable {
  final String id;
  final List<String> participants;
  final ChatParticipant other;

  final bool hasLastMessage;
  final String? lastMessageType;
  final String? lastMessageText;
  final bool lastMessageFromMe;

  final DateTime? lastMessageAt;
  final String timeLabel;

  /// Unread message count for the current user (drives the numeric badge).
  final int unreadCount;
  final List<String> blockedBy;

  const ChatThread({
    required this.id,
    this.participants = const <String>[],
    this.other = ChatParticipant.unknown,
    this.hasLastMessage = false,
    this.lastMessageType,
    this.lastMessageText,
    this.lastMessageFromMe = false,
    this.lastMessageAt,
    this.timeLabel = '',
    this.unreadCount = 0,
    this.blockedBy = const <String>[],
  });

  bool get hasUnread => unreadCount > 0;

  @override
  List<Object?> get props => <Object?>[
    id,
    participants,
    other,
    hasLastMessage,
    lastMessageType,
    lastMessageText,
    lastMessageFromMe,
    lastMessageAt,
    timeLabel,
    unreadCount,
    blockedBy,
  ];
}
