import 'package:json_annotation/json_annotation.dart';

part 'chat_last_message_response.g.dart';

/// Denormalized preview of a conversation's most recent message (stored on the
/// conversation doc so the list row renders without reading any message).
@JsonSerializable()
class ChatLastMessageResponse {
  final String? text;
  final String? type;
  final String? senderId;

  const ChatLastMessageResponse({this.text, this.type, this.senderId});

  factory ChatLastMessageResponse.fromJson(Map<String, dynamic> json) =>
      _$ChatLastMessageResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ChatLastMessageResponseToJson(this);
}
