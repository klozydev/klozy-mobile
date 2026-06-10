import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ui_kosmos_v4/ui_kosmos_v4.dart';

class MediaModelJsonConverter implements JsonConverter<MediaModel?, Object?> {
  const MediaModelJsonConverter();

  @override
  MediaModel? fromJson(Object? json) {
    if (json == null) return null;
    return MediaModel.fromJson(Map<String, dynamic>.from(json as Map<dynamic, dynamic>));
  }

  @override
  Object? toJson(MediaModel? item) => item?.toJson();
}