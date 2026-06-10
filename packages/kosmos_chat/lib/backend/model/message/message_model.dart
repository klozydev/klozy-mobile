import 'package:core_kosmos/core_kosmos.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kosmos_chat/backend/model/converters/list_media_converters.dart';
import 'package:kosmos_chat/backend/model/converters/message_converters.dart';
import 'package:ui_kosmos_v4/ui_kosmos_v4.dart';

part 'message_model.freezed.dart';
part 'message_model.g.dart';

@freezed
class MessageModel with _$MessageModel {
  const factory MessageModel({
    /// Principal data
    String? id,
    required String tchatId,
    required String senderId,

    /// Message data
    required String messageType,
    @MessageModelJsonConverter() MessageModel? replyTo,
    String? content,
    @Default({}) Map<dynamic, dynamic> metadata,
    @ListMediaModelJsonConverter() List<MediaModel>? media,

    /// Message status data
    @Default([]) List<String> readBy,
    @Default([]) List<String> deleteBy,
    @TimestampConverter() final DateTime? sendAt,
    final String? sendStatus,
    @Default(false) bool fromWeb,
  }) = _MessageModel;

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  factory MessageModel.fromCache(Map<String, dynamic> json) {
    final j = json;
    j["media"] = null;
    MessageModel m = _$MessageModelFromJson(j);
    m = m.copyWith(media: json["media"]);

    return m;
  }
}
