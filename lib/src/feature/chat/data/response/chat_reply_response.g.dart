// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_reply_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatReplyResponse _$ChatReplyResponseFromJson(Map<String, dynamic> json) =>
    ChatReplyResponse(
      id: json['id'] as String?,
      senderId: json['senderId'] as String?,
      type: json['type'] as String?,
      text: json['text'] as String?,
    );

Map<String, dynamic> _$ChatReplyResponseToJson(ChatReplyResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'senderId': instance.senderId,
      'type': instance.type,
      'text': instance.text,
    };
