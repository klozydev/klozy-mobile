// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tchat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TchatModelImpl _$$TchatModelImplFromJson(Map<String, dynamic> json) =>
    _$TchatModelImpl(
      id: json['id'] as String?,
      participants: (json['participants'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      allUserCanAdmin: json['allUserCanAdmin'] as bool? ?? false,
      deletedMessageHistory:
          (json['deletedMessageHistory'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k,
                    DeletedMessageHistory.fromJson(e as Map<String, dynamic>)),
              ) ??
              const {},
      isGroup: json['isGroup'] as bool? ?? false,
      type: $enumDecodeNullable(_$TchatTypeEnumMap, json['type']) ??
          TchatType.oneToOne,
      adminId: json['adminId'] as String?,
      mutedUsersList: (json['mutedUsersList'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      chatMutedBy: (json['chatMutedBy'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      tchatName: json['tchatName'] as String?,
      tchatPicture: json['tchatPicture'] as String?,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      closed: json['closed'] as bool? ?? false,
      lastMessage:
          const MessageModelJsonConverter().fromJson(json['lastMessage']),
      lastMessageSeenBy: (json['lastMessageSeenBy'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      lastMessageSentAt:
          const TimestampConverter().fromJson(json['lastMessageSentAt']),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      admins: (json['admins'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      deletedBy: (json['deletedBy'] as List<dynamic>?)
          ?.map((e) => TchatDeletedStatus.fromJson(e as Map<String, dynamic>))
          .toList(),
      blockedByUsers: (json['blockedByUsers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$TchatModelImplToJson(_$TchatModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'participants': instance.participants,
      'allUserCanAdmin': instance.allUserCanAdmin,
      'deletedMessageHistory':
          instance.deletedMessageHistory.map((k, e) => MapEntry(k, e.toJson())),
      'isGroup': instance.isGroup,
      'type': _$TchatTypeEnumMap[instance.type]!,
      'adminId': instance.adminId,
      'mutedUsersList': instance.mutedUsersList,
      'chatMutedBy': instance.chatMutedBy,
      'tchatName': instance.tchatName,
      'tchatPicture': instance.tchatPicture,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'closed': instance.closed,
      'lastMessage':
          const MessageModelJsonConverter().toJson(instance.lastMessage),
      'lastMessageSeenBy': instance.lastMessageSeenBy,
      'lastMessageSentAt':
          const TimestampConverter().toJson(instance.lastMessageSentAt),
      'metadata': instance.metadata,
      'admins': instance.admins,
      'deletedBy': instance.deletedBy?.map((e) => e.toJson()).toList(),
      'blockedByUsers': instance.blockedByUsers,
    };

const _$TchatTypeEnumMap = {
  TchatType.group: 'group',
  TchatType.oneToOne: 'oneToOne',
};

_$TchatDeletedStatusImpl _$$TchatDeletedStatusImplFromJson(
        Map<String, dynamic> json) =>
    _$TchatDeletedStatusImpl(
      userId: json['userId'] as String,
      deletedAt: const TimestampConverter().fromJson(json['deletedAt']),
    );

Map<String, dynamic> _$$TchatDeletedStatusImplToJson(
        _$TchatDeletedStatusImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'deletedAt': const TimestampConverter().toJson(instance.deletedAt),
    };
