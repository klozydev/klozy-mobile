// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConversationResponse _$ConversationResponseFromJson(
  Map<String, dynamic> json,
) => ConversationResponse(
  id: json['id'] as String?,
  participantIds: (json['participantIds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  participants: (json['participants'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(
      k,
      ChatParticipantResponse.fromJson(e as Map<String, dynamic>),
    ),
  ),
  lastMessage: json['lastMessage'] == null
      ? null
      : ChatLastMessageResponse.fromJson(
          json['lastMessage'] as Map<String, dynamic>,
        ),
  lastMessageAt: const TimestampConverter().fromJson(json['lastMessageAt']),
  unreadCounts: (json['unreadCounts'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toInt()),
  ),
  blockedBy: (json['blockedBy'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  deletedFor: (json['deletedFor'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$ConversationResponseToJson(
  ConversationResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'participantIds': instance.participantIds,
  'participants': instance.participants,
  'lastMessage': instance.lastMessage,
  'lastMessageAt': const TimestampConverter().toJson(instance.lastMessageAt),
  'unreadCounts': instance.unreadCounts,
  'blockedBy': instance.blockedBy,
  'deletedFor': instance.deletedFor,
};
