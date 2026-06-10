// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deleted_message_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DeletedMessageHistoryImpl _$$DeletedMessageHistoryImplFromJson(
        Map<String, dynamic> json) =>
    _$DeletedMessageHistoryImpl(
      lastMessage: json['lastMessage'] == null
          ? null
          : MessageModel.fromJson(json['lastMessage'] as Map<String, dynamic>),
      mostRecentDeletedMessageDate: const TimestampConverter()
          .fromJson(json['mostRecentDeletedMessageDate']),
      mostRecentDeletedMessageId: json['mostRecentDeletedMessageId'] as String?,
    );

Map<String, dynamic> _$$DeletedMessageHistoryImplToJson(
        _$DeletedMessageHistoryImpl instance) =>
    <String, dynamic>{
      'lastMessage': instance.lastMessage?.toJson(),
      'mostRecentDeletedMessageDate': const TimestampConverter()
          .toJson(instance.mostRecentDeletedMessageDate),
      'mostRecentDeletedMessageId': instance.mostRecentDeletedMessageId,
    };
