import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/domain/orders/entity/order_action.dart';
import 'package:klozy/src/domain/orders/orders_repository.dart';
import 'package:klozy/src/feature/orders/presentation/bloc/order_detail_event.dart';
import 'package:klozy/src/feature/orders/presentation/bloc/order_detail_state.dart';

@injectable
class OrderDetailBloc extends Bloc<OrderDetailEvent, OrderDetailState> {
  final OrdersRepository _repository;

  OrderDetailBloc(this._repository) : super(const OrderDetailLoadingState()) {
    on<OrderDetailStarted>(_onStarted);
    on<OrderActionRequested>(_onAction);
  }

  Future<void> _onStarted(
    OrderDetailStarted event,
    Emitter<OrderDetailState> emit,
  ) async {
    emit(const OrderDetailLoadingState());
    await _load(event.id, emit);
  }

  Future<void> _onAction(
    OrderActionRequested event,
    Emitter<OrderDetailState> emit,
  ) async {
    final current = state;
    if (current is! OrderDetailLoadedState) return;
    final id = current.order.id;
    emit(OrderDetailLoadedState(current.order, isActing: true));
    try {
      switch (event.action) {
        case OrderAction.ship:
          await _repository.ship(id);
        case OrderAction.confirmReceipt:
          await _repository.confirmReceipt(id);
        case OrderAction.reportProblem:
          await _repository.reportProblem(id, event.reason ?? '');
        case OrderAction.cancel:
          await _repository.cancel(id);
        case OrderAction.review:
          await _repository.review(
            id,
            rating: event.rating ?? 5,
            body: event.body,
          );
        case OrderAction.acceptReturn:
          await _repository.acceptReturn(id);
        case OrderAction.refuseReturn:
          await _repository.refuseReturn(id, reason: event.reason ?? '');
      }
    } catch (_) {}
    await _load(id, emit);
  }

  Future<void> _load(String id, Emitter<OrderDetailState> emit) async {
    try {
      emit(OrderDetailLoadedState(await _repository.getOrder(id)));
    } catch (error) {
      if (state is! OrderDetailLoadedState) {
        emit(OrderDetailErrorState(type: AppErrorType.fromException(error)));
      }
    }
  }
}
