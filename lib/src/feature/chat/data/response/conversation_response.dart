import 'package:json_annotation/json_annotation.dart';
import 'package:klozy/src/feature/chat/data/converter/timestamp_converter.dart';
import 'package:klozy/src/feature/chat/data/response/chat_last_message_response.dart';
import 'package:klozy/src/feature/chat/data/response/chat_participant_response.dart';

part 'conversation_response.g.dart';

/// A 1:1 conversation doc (`conversations/{id}`). Fully denormalized: the
/// `participants` map and per-user `unreadCounts` mean the list query needs no
/// joins and no per-message reads.
@JsonSerializable()
class ConversationResponse {
  final String? id;
  final List<String>? participantIds;
  final Map<String, ChatParticipantResponse>? participants;
  final ChatLastMessageResponse? lastMessage;

  @TimestampConverter()
  final DateTime? lastMessageAt;
  final Map<String, int>? unreadCounts;
  final List<String>? blockedBy;
  final List<String>? deletedFor;

  const ConversationResponse({
    this.id,
    this.participantIds,
    this.participants,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCounts,
    this.blockedBy,
    this.deletedFor,
  });

  factory ConversationResponse.fromJson(Map<String, dynamic> json) =>
      _$ConversationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationResponseToJson(this);
}
