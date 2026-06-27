import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/orders/entity/order.dart';
import 'package:klozy/src/domain/orders/entity/order_action.dart';
import 'package:klozy/src/domain/orders/entity/order_status.dart';
import 'package:klozy/src/domain/orders/orders_repository.dart';
import 'package:klozy/src/domain/product/entity/product_detail.dart';
import 'package:klozy/src/feature/orders/presentation/bloc/order_detail_bloc.dart';
import 'package:klozy/src/feature/orders/presentation/bloc/order_detail_event.dart';
import 'package:klozy/src/feature/orders/presentation/bloc/order_detail_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockOrdersRepository extends Mock implements OrdersRepository {}

Future<List<OrderDetailState>> _collectStates(
  OrderDetailBloc bloc,
  OrderDetailEvent event,
) async {
  final states = <OrderDetailState>[];
  final sub = bloc.stream.listen(states.add);
  bloc.add(event);
  await Future<void>.delayed(Duration.zero);
  await sub.cancel();
  return states;
}

const _kSeller = ProductSeller(id: 's1');
const _kOrder = Order(
  id: 'order1',
  status: OrderStatus.pending,
  viewerRole: OrderRole.buyer,
  counterpart: _kSeller,
  availableActions: <OrderAction>{OrderAction.cancel},
);

void main() {
  late _MockOrdersRepository mockRepo;
  late OrderDetailBloc bloc;

  setUp(() {
    mockRepo = _MockOrdersRepository();
    bloc = OrderDetailBloc(mockRepo);
  });

  tearDown(() => bloc.close());

  test('initial state is OrderDetailLoadingState', () {
    expect(bloc.state, const OrderDetailLoadingState());
  });

  group('OrderDetailStarted', () {
    test('emits [loading, loaded] on success', () async {
      when(() => mockRepo.getOrder(any())).thenAnswer((_) async => _kOrder);

      final states = await _collectStates(
        bloc,
        const OrderDetailStarted('order1'),
      );

      expect(states.first, const OrderDetailLoadingState());
      final loaded = states.last as OrderDetailLoadedState;
      expect(loaded.order.id, 'order1');
    });

    test('emits [loading, error] on failure', () async {
      when(() => mockRepo.getOrder(any())).thenThrow(Exception('network'));

      final states = await _collectStates(
        bloc,
        const OrderDetailStarted('order1'),
      );

      expect(states.first, const OrderDetailLoadingState());
      expect(states.last, isA<OrderDetailErrorState>());
    });
  });

  group('OrderActionRequested', () {
    Future<void> loadOrder() async {
      when(() => mockRepo.getOrder(any())).thenAnswer((_) async => _kOrder);
      final sub = bloc.stream.listen((_) {});
      bloc.add(const OrderDetailStarted('order1'));
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
    }

    test('cancel: calls cancel and reloads', () async {
      await loadOrder();
      when(() => mockRepo.cancel(any())).thenAnswer((_) async {});

      final states = await _collectStates(
        bloc,
        const OrderActionRequested(OrderAction.cancel),
      );

      expect((states.first as OrderDetailLoadedState).isActing, isTrue);
      verify(() => mockRepo.cancel('order1')).called(1);
      verify(() => mockRepo.getOrder('order1')).called(2); // initial + reload
    });

    test('ship: calls ship and reloads', () async {
      await loadOrder();
      when(() => mockRepo.ship(any())).thenAnswer((_) async {});

      await _collectStates(bloc, const OrderActionRequested(OrderAction.ship));

      verify(() => mockRepo.ship('order1')).called(1);
    });

    test('confirmReceipt: calls confirmReceipt and reloads', () async {
      await loadOrder();
      when(() => mockRepo.confirmReceipt(any())).thenAnswer((_) async {});

      await _collectStates(
        bloc,
        const OrderActionRequested(OrderAction.confirmReceipt),
      );

      verify(() => mockRepo.confirmReceipt('order1')).called(1);
    });

    test('reportProblem: calls reportProblem with reason', () async {
      await loadOrder();
      when(() => mockRepo.reportProblem(any(), any())).thenAnswer((_) async {});

      await _collectStates(
        bloc,
        const OrderActionRequested(OrderAction.reportProblem, reason: 'broken'),
      );

      verify(() => mockRepo.reportProblem('order1', 'broken')).called(1);
    });

    test('review: calls review with rating and body', () async {
      await loadOrder();
      when(
        () => mockRepo.review(
          any(),
          rating: any(named: 'rating'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async {});

      await _collectStates(
        bloc,
        const OrderActionRequested(
          OrderAction.review,
          rating: 4,
          body: 'Great!',
        ),
      );

      verify(
        () => mockRepo.review('order1', rating: 4, body: 'Great!'),
      ).called(1);
    });

    test('still reloads when action throws', () async {
      await loadOrder();
      when(() => mockRepo.cancel(any())).thenThrow(Exception('server'));

      await _collectStates(
        bloc,
        const OrderActionRequested(OrderAction.cancel),
      );

      // getOrder called once for initial load + once for reload after error
      verify(() => mockRepo.getOrder('order1')).called(2);
    });

    test('does nothing when state is not loaded', () async {
      // State is still OrderDetailLoadingState
      final states = await _collectStates(
        bloc,
        const OrderActionRequested(OrderAction.cancel),
      );
      expect(states, isEmpty);
    });
  });
}
