// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_last_message_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatLastMessageResponse _$ChatLastMessageResponseFromJson(
  Map<String, dynamic> json,
) => ChatLastMessageResponse(
  text: json['text'] as String?,
  type: json['type'] as String?,
  senderId: json['senderId'] as String?,
);

Map<String, dynamic> _$ChatLastMessageResponseToJson(
  ChatLastMessageResponse instance,
) => <String, dynamic>{
  'text': instance.text,
  'type': instance.type,
  'senderId': instance.senderId,
};
