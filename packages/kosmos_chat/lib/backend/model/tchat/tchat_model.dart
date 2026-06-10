import 'package:core_kosmos/core_kosmos.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kosmos_chat/backend/kosmos_chat_backend.dart';
import 'package:kosmos_chat/backend/model/converters/message_converters.dart';
import 'package:kosmos_chat/backend/model/deletedMessageHistory/deleted_message_history.dart';

part 'tchat_model.freezed.dart';
part 'tchat_model.g.dart';

@freezed
class TchatModel with _$TchatModel {
  const factory TchatModel({
    final String? id,

    ///Tchat data
    required final List<String> participants,
    // admin give permission to all users to admin the tchat only for changing tchat name and picture and adding new users
    @Default(false) final bool allUserCanAdmin,
    @Default({}) final Map<String, DeletedMessageHistory> deletedMessageHistory,

    /// Group data
    @Default(false) final bool isGroup,
    @Default(TchatType.oneToOne) final TchatType type,
    final String? adminId,
    // maps to refer when user X muted user Y => X_Y
    @Default([]) final List<String> mutedUsersList,
    // maps to refer when user X muted all users
    @Default([]) final List<String> chatMutedBy,
    final String? tchatName,
    final String? tchatPicture,
    @TimestampConverter() final DateTime? createdAt,
    @Default(false) bool closed,

    /// Last message data
    @MessageModelJsonConverter() final MessageModel? lastMessage,
    @Default([]) final List<String> lastMessageSeenBy,
    @TimestampConverter() final DateTime? lastMessageSentAt,
    @Default({}) final Map<String, dynamic> metadata,
    @Default([]) final List<String> admins,

    /// Deleted status
    final List<TchatDeletedStatus>? deletedBy,

    // Blocked status (only for [TchatType.oneToOne] tchat)
    @Default([]) final List<String> blockedByUsers,
  }) = _TchatModel;

  factory TchatModel.fromJson(Map<String, dynamic> json) =>
      _$TchatModelFromJson(json);

  factory TchatModel.fromCache(Map<String, dynamic> json) {
    final last = json["lastMessage"];
    if (json["lastMessage"] != null) json["lastMessage"] = null;
    return _$TchatModelFromJson(json).copyWith(lastMessage: last);
  }
}

@freezed
class TchatDeletedStatus with _$TchatDeletedStatus {
  const factory TchatDeletedStatus({
    required final String userId,
    @TimestampConverter() final DateTime? deletedAt,
  }) = _TchatDeletedStatus;

  factory TchatDeletedStatus.fromJson(Map<String, dynamic> json) =>
      _$TchatDeletedStatusFromJson(json);
}
