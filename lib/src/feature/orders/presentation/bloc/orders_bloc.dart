import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/domain/orders/entity/order_action.dart';
import 'package:klozy/src/domain/orders/entity/order_list_item.dart';
import 'package:klozy/src/domain/orders/orders_repository.dart';
import 'package:klozy/src/feature/orders/presentation/bloc/orders_event.dart';
import 'package:klozy/src/feature/orders/presentation/bloc/orders_state.dart';

@injectable
class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final OrdersRepository _repository;

  OrdersBloc(this._repository) : super(const OrdersLoadingState()) {
    on<OrdersStarted>(
      (OrdersStarted event, Emitter<OrdersState> emit) =>
          _load(OrderRole.buyer, emit),
    );
    on<OrdersRoleChanged>(
      (OrdersRoleChanged event, Emitter<OrdersState> emit) =>
          _load(event.role, emit),
    );
  }

  Future<void> _load(OrderRole role, Emitter<OrdersState> emit) async {
    emit(OrdersLoadingState(role: role));
    try {
      final results =
          await Future.wait<List<OrderListItem>>(<Future<List<OrderListItem>>>[
            _repository.getOrders(role: role, state: OrderListState.inProgress),
            _repository.getOrders(role: role, state: OrderListState.completed),
          ]);
      emit(
        OrdersLoadedState(
          role: role,
          inProgress: results[0],
          completed: results[1],
        ),
      );
    } catch (error) {
      emit(
        OrdersErrorState(type: AppErrorType.fromException(error), role: role),
      );
    }
  }
}
