// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tchat_status_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TchatStatusModelImpl _$$TchatStatusModelImplFromJson(
        Map<String, dynamic> json) =>
    _$TchatStatusModelImpl(
      tchatId: json['tchatId'] as String,
      status: (json['status'] as List<dynamic>?)
              ?.map((e) =>
                  TchatUserStatusModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$TchatStatusModelImplToJson(
        _$TchatStatusModelImpl instance) =>
    <String, dynamic>{
      'tchatId': instance.tchatId,
      'status': instance.status.map((e) => e.toJson()).toList(),
    };

_$TchatUserStatusModelImpl _$$TchatUserStatusModelImplFromJson(
        Map<String, dynamic> json) =>
    _$TchatUserStatusModelImpl(
      userId: json['userId'] as String,
      status: $enumDecode(_$TchatingStatusEnumMap, json['status']),
      lastUpdate: json['lastUpdate'] == null
          ? null
          : DateTime.parse(json['lastUpdate'] as String),
    );

Map<String, dynamic> _$$TchatUserStatusModelImplToJson(
        _$TchatUserStatusModelImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'status': _$TchatingStatusEnumMap[instance.status]!,
      'lastUpdate': instance.lastUpdate?.toIso8601String(),
    };

const _$TchatingStatusEnumMap = {
  TchatingStatus.offline: 'offline',
  TchatingStatus.online: 'online',
  TchatingStatus.multipleOnline: 'multipleOnline',
  TchatingStatus.typing: 'typing',
  TchatingStatus.audioRec: 'audioRec',
};
