import 'package:json_annotation/json_annotation.dart';

part 'chat_reply_response.g.dart';

/// Slim quoted-message payload embedded under a message's `replyTo`.
@JsonSerializable()
class ChatReplyResponse {
  final String? id;
  final String? senderId;
  final String? type;
  final String? text;

  const ChatReplyResponse({this.id, this.senderId, this.type, this.text});

  factory ChatReplyResponse.fromJson(Map<String, dynamic> json) =>
      _$ChatReplyResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ChatReplyResponseToJson(this);
}
