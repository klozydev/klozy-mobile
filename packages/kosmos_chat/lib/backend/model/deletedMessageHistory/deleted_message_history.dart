import 'package:core_kosmos/core_kosmos.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kosmos_chat/backend/kosmos_chat_backend.dart';

part 'deleted_message_history.freezed.dart';
part 'deleted_message_history.g.dart';

// mostRecentDeletedMessage can be diffrerent from lastMessage.sentAt
@freezed
class DeletedMessageHistory with _$DeletedMessageHistory {
  const factory DeletedMessageHistory({
    MessageModel? lastMessage,
    @TimestampConverter() DateTime? mostRecentDeletedMessageDate,
    String? mostRecentDeletedMessageId,
  }) = _DeletedMessageHistory;

  factory DeletedMessageHistory.fromJson(Map<String, dynamic> json) =>
      _$DeletedMessageHistoryFromJson(json);
}
