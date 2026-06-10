import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kosmos_chat/backend/controller/status_controller.dart';

part 'tchat_status_model.freezed.dart';
part 'tchat_status_model.g.dart';

@freezed
class TchatStatusModel with _$TchatStatusModel {
  const factory TchatStatusModel({
    required String tchatId,
    @Default([]) List<TchatUserStatusModel> status,
  }) = _TchatStatusModel;

  factory TchatStatusModel.fromJson(Map<String, dynamic> json) =>
      _$TchatStatusModelFromJson(json);
}

@freezed
class TchatUserStatusModel with _$TchatUserStatusModel {
  const factory TchatUserStatusModel({
    required String userId,
    required TchatingStatus status,
    DateTime? lastUpdate,
  }) = _TchatUserStatusModel;

  factory TchatUserStatusModel.fromJson(Map<String, dynamic> json) =>
      _$TchatUserStatusModelFromJson(json);
}
