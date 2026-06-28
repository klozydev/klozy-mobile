import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/domain/orders/entity/order_action.dart';
import 'package:klozy/src/domain/orders/entity/order_list_item.dart';
import 'package:klozy/src/domain/orders/entity/order_status.dart';
import 'package:klozy/src/domain/orders/orders_repository.dart';
import 'package:klozy/src/feature/orders/presentation/bloc/orders_bloc.dart';
import 'package:klozy/src/feature/orders/presentation/bloc/orders_event.dart';
import 'package:klozy/src/feature/orders/presentation/bloc/orders_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockOrdersRepository extends Mock implements OrdersRepository {}

Future<List<OrdersState>> _collectStates(
  OrdersBloc bloc,
  OrdersEvent event,
) async {
  final states = <OrdersState>[];
  final sub = bloc.stream.listen(states.add);
  bloc.add(event);
  await Future<void>.delayed(Duration.zero);
  await sub.cancel();
  return states;
}

const _kItem = OrderListItem(
  id: 'o1',
  title: 'Item 1',
  price: 100,
  status: OrderStatus.pending,
);

void main() {
  late _MockOrdersRepository mockRepo;
  late OrdersBloc bloc;

  setUpAll(() {
    registerFallbackValue(OrderRole.buyer);
  });

  setUp(() {
    mockRepo = _MockOrdersRepository();
    bloc = OrdersBloc(mockRepo);
  });

  tearDown(() => bloc.close());

  test('initial state is OrdersLoadingState(buyer)', () {
    expect(bloc.state, const OrdersLoadingState(role: OrderRole.buyer));
  });

  group('OrdersStarted', () {
    test('emits [loading(buyer), loaded(buyer)] on success', () async {
      when(
        () => mockRepo.getOrders(
          role: any(named: 'role'),
          state: any(named: 'state'),
        ),
      ).thenAnswer((_) async => <OrderListItem>[_kItem]);

      final states = await _collectStates(bloc, const OrdersStarted());

      expect(states.first, const OrdersLoadingState(role: OrderRole.buyer));
      final last = states.last as OrdersLoadedState;
      expect(last.role, OrderRole.buyer);
      expect(last.inProgress, [_kItem]);
    });

    test('emits [loading(buyer), error(buyer)] on failure', () async {
      when(
        () => mockRepo.getOrders(
          role: any(named: 'role'),
          state: any(named: 'state'),
        ),
      ).thenThrow(Exception('network'));

      final states = await _collectStates(bloc, const OrdersStarted());

      expect(states.first, const OrdersLoadingState(role: OrderRole.buyer));
      final last = states.last as OrdersErrorState;
      expect(last.role, OrderRole.buyer);
      expect(last.type, AppErrorType.unknown);
    });
  });

  group('OrdersRoleChanged', () {
    test('emits [loading(seller), loaded(seller)] on success', () async {
      when(
        () => mockRepo.getOrders(
          role: any(named: 'role'),
          state: any(named: 'state'),
        ),
      ).thenAnswer((_) async => <OrderListItem>[]);

      final states = await _collectStates(
        bloc,
        const OrdersRoleChanged(OrderRole.seller),
      );

      expect(states.first, const OrdersLoadingState(role: OrderRole.seller));
      final last = states.last as OrdersLoadedState;
      expect(last.role, OrderRole.seller);
    });

    test('emits [loading(seller), error(seller)] on failure', () async {
      when(
        () => mockRepo.getOrders(
          role: any(named: 'role'),
          state: any(named: 'state'),
        ),
      ).thenThrow(Exception('network'));

      final states = await _collectStates(
        bloc,
        const OrdersRoleChanged(OrderRole.seller),
      );

      final last = states.last as OrdersErrorState;
      expect(last.role, OrderRole.seller);
    });
  });
}
