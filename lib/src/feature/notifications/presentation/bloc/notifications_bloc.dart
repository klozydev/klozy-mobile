import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
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

  static const int _limit = 30;
  int _page = 1;

  NotificationsBloc(this._repository, this._cubit)
    : super(const NotificationsLoadingState()) {
    on<NotificationsStarted>(_onStarted);
    on<NotificationsLoadMore>(_onLoadMore, transformer: droppable());
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
      _page = 1;
      final items = await _repository.getNotifications(
        page: _page,
        limit: _limit,
      );
      emit(NotificationsLoadedState(items, hasMore: items.length >= _limit));
    } catch (error) {
      emit(NotificationsErrorState(type: AppErrorType.fromException(error)));
    }
  }

  Future<void> _onLoadMore(
    NotificationsLoadMore event,
    Emitter<NotificationsState> emit,
  ) async {
    final current = state;
    if (current is! NotificationsLoadedState ||
        current.isLoadingMore ||
        !current.hasMore) {
      return;
    }
    emit(current.copyWith(isLoadingMore: true));
    try {
      final items = await _repository.getNotifications(
        page: _page + 1,
        limit: _limit,
      );
      final latest = state;
      if (emit.isDone || latest is! NotificationsLoadedState) return;
      _page += 1;
      emit(
        NotificationsLoadedState(<AppNotification>[
          ...latest.items,
          ...items,
        ], hasMore: items.length >= _limit),
      );
    } catch (_) {
      final latest = state;
      if (!emit.isDone && latest is NotificationsLoadedState) {
        emit(latest.copyWith(isLoadingMore: false));
      }
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
