// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_media_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMediaResponse _$ChatMediaResponseFromJson(Map<String, dynamic> json) =>
    ChatMediaResponse(
      id: json['id'] as String?,
      url: json['url'] as String?,
      type: json['type'] as String?,
      name: json['name'] as String?,
      width: (json['width'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      durationMs: (json['durationMs'] as num?)?.toInt(),
      thumbnailUrl: json['thumbnailUrl'] as String?,
      relativePath: json['relativePath'] as String?,
    );

Map<String, dynamic> _$ChatMediaResponseToJson(ChatMediaResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'type': instance.type,
      'name': instance.name,
      'width': instance.width,
      'height': instance.height,
      'durationMs': instance.durationMs,
      'thumbnailUrl': instance.thumbnailUrl,
      'relativePath': instance.relativePath,
    };
