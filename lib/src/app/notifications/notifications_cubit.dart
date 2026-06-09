import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/domain/notifications/notifications_repository.dart';

/// App-wide unread-notification count — backs the Home header bell badge.
@lazySingleton
class NotificationsCubit extends Cubit<int> {
  final NotificationsRepository _repository;

  NotificationsCubit(this._repository) : super(0);

  Future<void> load() async {
    try {
      emit(await _repository.unreadCount());
    } catch (_) {}
  }

  Future<void> refresh() => load();

  void clear() => emit(0);
}
