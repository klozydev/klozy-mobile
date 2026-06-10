// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MessageModelImpl _$$MessageModelImplFromJson(Map<String, dynamic> json) =>
    _$MessageModelImpl(
      id: json['id'] as String?,
      tchatId: json['tchatId'] as String,
      senderId: json['senderId'] as String,
      messageType: json['messageType'] as String,
      replyTo: const MessageModelJsonConverter().fromJson(json['replyTo']),
      content: json['content'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      media: (json['media'] as List<dynamic>?)
          ?.map((e) => MediaModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      readBy: (json['readBy'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      deleteBy: (json['deleteBy'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      sendAt: const TimestampConverter().fromJson(json['sendAt']),
      sendStatus: json['sendStatus'] as String?,
      fromWeb: json['fromWeb'] as bool? ?? false,
    );

Map<String, dynamic> _$$MessageModelImplToJson(_$MessageModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tchatId': instance.tchatId,
      'senderId': instance.senderId,
      'messageType': instance.messageType,
      'replyTo': const MessageModelJsonConverter().toJson(instance.replyTo),
      'content': instance.content,
      'metadata': instance.metadata,
      'media': instance.media?.map((e) => e.toJson()).toList(),
      'readBy': instance.readBy,
      'deleteBy': instance.deleteBy,
      'sendAt': const TimestampConverter().toJson(instance.sendAt),
      'sendStatus': instance.sendStatus,
      'fromWeb': instance.fromWeb,
    };
