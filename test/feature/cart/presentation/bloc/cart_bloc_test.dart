import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/app/cart/cart_cubit.dart';
import 'package:klozy/src/domain/cart/cart_repository.dart';
import 'package:klozy/src/domain/cart/entity/cart.dart';
import 'package:klozy/src/domain/offers/offers_repository.dart';
import 'package:klozy/src/feature/cart/presentation/bloc/cart_bloc.dart';
import 'package:klozy/src/feature/cart/presentation/bloc/cart_event.dart';
import 'package:klozy/src/feature/cart/presentation/bloc/cart_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockCartRepository extends Mock implements CartRepository {}

class _MockOffersRepository extends Mock implements OffersRepository {}

class _MockCartCubit extends Mock implements CartCubit {}

Future<List<CartState>> _collectStates(CartBloc bloc, CartEvent event) async {
  final states = <CartState>[];
  final sub = bloc.stream.listen(states.add);
  bloc.add(event);
  await Future<void>.delayed(Duration.zero);
  await sub.cancel();
  return states;
}

void main() {
  late _MockCartRepository mockCartRepo;
  late _MockOffersRepository mockOffersRepo;
  late _MockCartCubit mockCubit;
  late CartBloc bloc;

  setUp(() {
    mockCartRepo = _MockCartRepository();
    mockOffersRepo = _MockOffersRepository();
    mockCubit = _MockCartCubit();
    when(() => mockCubit.load()).thenAnswer((_) async {});
    bloc = CartBloc(mockCartRepo, mockOffersRepo, mockCubit);
  });

  tearDown(() => bloc.close());

  test('initial state is CartLoadingState', () {
    expect(bloc.state, const CartLoadingState());
  });

  group('CartStarted', () {
    test('emits [loading, loaded] on success', () async {
      when(() => mockCartRepo.getCart()).thenAnswer((_) async => Cart.empty);

      final states = await _collectStates(bloc, const CartStarted());

      expect(states.first, const CartLoadingState());
      final loaded = states.last as CartLoadedState;
      expect(loaded.cart, Cart.empty);
    });

    test('emits [loading, error] on failure', () async {
      when(() => mockCartRepo.getCart()).thenThrow(Exception('network'));

      final states = await _collectStates(bloc, const CartStarted());

      expect(states.first, const CartLoadingState());
      expect(states.last, isA<CartErrorState>());
    });
  });

  group('CartItemRemoved', () {
    Future<void> loadCart() async {
      when(() => mockCartRepo.getCart()).thenAnswer((_) async => Cart.empty);
      final sub = bloc.stream.listen((_) {});
      bloc.add(const CartStarted());
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
    }

    test('removes item and reloads', () async {
      await loadCart();
      when(() => mockCartRepo.removeItem(any())).thenAnswer((_) async {});

      final states = await _collectStates(bloc, const CartItemRemoved('p1'));

      verify(() => mockCartRepo.removeItem('p1')).called(1);
      final last = states.last as CartLoadedState;
      expect(last.isMutating, isFalse);
    });

    test('still reloads when removeItem throws (error is swallowed)', () async {
      await loadCart();
      when(() => mockCartRepo.removeItem(any())).thenThrow(Exception('server'));

      final states = await _collectStates(bloc, const CartItemRemoved('p1'));

      // Reload still happens
      final last = states.last as CartLoadedState;
      expect(last.cart, Cart.empty);
    });
  });

  group('CartOfferMade', () {
    Future<void> loadCart() async {
      when(() => mockCartRepo.getCart()).thenAnswer((_) async => Cart.empty);
      final sub = bloc.stream.listen((_) {});
      bloc.add(const CartStarted());
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
    }

    test('makes offer and reloads', () async {
      await loadCart();
      when(
        () => mockOffersRepo.makeOffer(
          productIds: any(named: 'productIds'),
          amount: any(named: 'amount'),
        ),
      ).thenAnswer((_) async {});

      final states = await _collectStates(
        bloc,
        const CartOfferMade(productIds: ['p1', 'p2'], amount: 150),
      );

      verify(
        () => mockOffersRepo.makeOffer(productIds: ['p1', 'p2'], amount: 150),
      ).called(1);
      expect(states.last, isA<CartLoadedState>());
    });
  });

  group('CartOfferCancelled', () {
    Future<void> loadCart() async {
      when(() => mockCartRepo.getCart()).thenAnswer((_) async => Cart.empty);
      final sub = bloc.stream.listen((_) {});
      bloc.add(const CartStarted());
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
    }

    test('cancels offer and reloads', () async {
      await loadCart();
      when(() => mockOffersRepo.cancelOffer(any())).thenAnswer((_) async {});

      final states = await _collectStates(
        bloc,
        const CartOfferCancelled('offer1'),
      );

      verify(() => mockOffersRepo.cancelOffer('offer1')).called(1);
      expect(states.last, isA<CartLoadedState>());
    });
  });
}
