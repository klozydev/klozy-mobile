// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMessageResponse _$ChatMessageResponseFromJson(
  Map<String, dynamic> json,
) => ChatMessageResponse(
  id: json['id'] as String?,
  conversationId: json['conversationId'] as String?,
  senderId: json['senderId'] as String?,
  type: json['type'] as String?,
  text: json['text'] as String?,
  media: (json['media'] as List<dynamic>?)
      ?.map((e) => ChatMediaResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
  replyTo: json['replyTo'] == null
      ? null
      : ChatReplyResponse.fromJson(json['replyTo'] as Map<String, dynamic>),
  offer: json['offer'] == null
      ? null
      : ChatOfferResponse.fromJson(json['offer'] as Map<String, dynamic>),
  purchase: json['purchase'] == null
      ? null
      : ChatPurchaseResponse.fromJson(json['purchase'] as Map<String, dynamic>),
  readBy: (json['readBy'] as List<dynamic>?)?.map((e) => e as String).toList(),
  clientId: json['clientId'] as String?,
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
);

Map<String, dynamic> _$ChatMessageResponseToJson(
  ChatMessageResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'conversationId': instance.conversationId,
  'senderId': instance.senderId,
  'type': instance.type,
  'text': instance.text,
  'media': instance.media,
  'replyTo': instance.replyTo,
  'offer': instance.offer,
  'purchase': instance.purchase,
  'readBy': instance.readBy,
  'clientId': instance.clientId,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
};
