// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_participant_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatParticipantResponse _$ChatParticipantResponseFromJson(
  Map<String, dynamic> json,
) => ChatParticipantResponse(
  userId: json['userId'] as String?,
  displayName: json['displayName'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  rating: json['rating'] as num?,
  isPro: json['isPro'] as bool?,
);

Map<String, dynamic> _$ChatParticipantResponseToJson(
  ChatParticipantResponse instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'displayName': instance.displayName,
  'avatarUrl': instance.avatarUrl,
  'rating': instance.rating,
  'isPro': instance.isPro,
};
