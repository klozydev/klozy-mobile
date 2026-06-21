import 'package:json_annotation/json_annotation.dart';

part 'chat_participant_response.g.dart';

/// A participant's denormalized display data, embedded in a conversation's
/// `participants` map (keyed by Firebase UID) — so the list needs no join.
@JsonSerializable()
class ChatParticipantResponse {
  final String? userId;
  final String? displayName;
  final String? avatarUrl;
  final num? rating;
  final bool? isPro;

  const ChatParticipantResponse({
    this.userId,
    this.displayName,
    this.avatarUrl,
    this.rating,
    this.isPro,
  });

  factory ChatParticipantResponse.fromJson(Map<String, dynamic> json) =>
      _$ChatParticipantResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ChatParticipantResponseToJson(this);
}
