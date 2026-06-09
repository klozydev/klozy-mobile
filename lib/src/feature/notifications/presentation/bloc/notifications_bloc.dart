import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/app/notifications/notifications_cubit.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/domain/notifications/entity/app_notification.dart';
import 'package:klozy/src/domain/notifications/notifications_repository.dart';
import 'package:klozy/src/feature/notifications/presentation/bloc/notifications_event.dart';
import 'package:klozy/src/feature/notifications/presentation/bloc/notifications_state.dart';

@injectable
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationsRepository _repository;
  final NotificationsCubit _cubit;

  NotificationsBloc(this._repository, this._cubit)
    : super(const NotificationsLoadingState()) {
    on<NotificationsStarted>(_onStarted);
    on<NotificationsReadAll>(_onReadAll);
    on<NotificationMarkedRead>(_onMarkedRead);
    on<NotificationRemoved>(_onRemoved);
  }

  Future<void> _onStarted(
    NotificationsStarted event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(const NotificationsLoadingState());
    try {
      emit(NotificationsLoadedState(await _repository.getNotifications()));
    } catch (error) {
      emit(NotificationsErrorState(type: AppErrorType.fromException(error)));
    }
  }

  Future<void> _onReadAll(
    NotificationsReadAll event,
    Emitter<NotificationsState> emit,
  ) async {
    final current = state;
    if (current is! NotificationsLoadedState) return;
    if (current.items.every((AppNotification n) => n.read)) return;
    emit(
      NotificationsLoadedState(
        current.items
            .map((AppNotification n) => n.copyWith(read: true))
            .toList(),
      ),
    );
    try {
      await _repository.markAllRead();
    } catch (_) {}
    _cubit.clear();
  }

  Future<void> _onMarkedRead(
    NotificationMarkedRead event,
    Emitter<NotificationsState> emit,
  ) async {
    final current = state;
    if (current is! NotificationsLoadedState) return;
    emit(
      NotificationsLoadedState(
        current.items
            .map(
              (AppNotification n) =>
                  n.id == event.id ? n.copyWith(read: true) : n,
            )
            .toList(),
      ),
    );
    try {
      await _repository.markRead(event.id);
    } catch (_) {}
    await _cubit.refresh();
  }

  Future<void> _onRemoved(
    NotificationRemoved event,
    Emitter<NotificationsState> emit,
  ) async {
    final current = state;
    if (current is! NotificationsLoadedState) return;
    emit(
      NotificationsLoadedState(
        current.items.where((AppNotification n) => n.id != event.id).toList(),
      ),
    );
    try {
      await _repository.remove(event.id);
    } catch (_) {}
    await _cubit.refresh();
  }
}
