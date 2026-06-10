import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kosmos_chat/backend/kosmos_chat_backend.dart';

class MessageModelJsonConverter implements JsonConverter<MessageModel?, Object?> {
  const MessageModelJsonConverter();

  @override
  MessageModel? fromJson(Object? json) {
    if (json == null) return null;
    return MessageModel.fromJson(Map<String, dynamic>.from(json as Map<dynamic, dynamic>));
  }

  @override
  Object? toJson(MessageModel? item) => item?.toJson();
}