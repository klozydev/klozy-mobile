import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ui_kosmos_v4/ui_kosmos_v4.dart';

class ListMediaModelJsonConverter implements JsonConverter<List<MediaModel?>?, Object?> {
  const ListMediaModelJsonConverter();

  @override
  List<MediaModel?>? fromJson(Object? json) {
    if (json == null) return null;
    List<MediaModel?> ret = [];

    for (final item in (json as List<dynamic>)) {
      ret.add(MediaModel.fromJson(Map<String, dynamic>.from(item as Map<dynamic, dynamic>)));
    }

    return ret;
  }

  @override
  Object? toJson(List<MediaModel?>? item) => item?.map((e) => e?.toJson()).toList();
}