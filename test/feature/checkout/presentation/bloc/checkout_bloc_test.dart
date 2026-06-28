import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/app/cart/cart_cubit.dart';
import 'package:klozy/src/domain/cart/entity/cart.dart';
import 'package:klozy/src/domain/cart/entity/cart_item.dart';
import 'package:klozy/src/domain/checkout/checkout_repository.dart';
import 'package:klozy/src/domain/checkout/entity/checkout_quote.dart';
import 'package:klozy/src/domain/checkout/entity/checkout_result.dart';
import 'package:klozy/src/domain/checkout/entity/order_fees.dart';
import 'package:klozy/src/domain/checkout/entity/order_summary.dart';
import 'package:klozy/src/domain/checkout/entity/payment_sheet_data.dart';
import 'package:klozy/src/domain/me/entity/address.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:klozy/src/feature/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:klozy/src/feature/checkout/presentation/bloc/checkout_event.dart';
import 'package:klozy/src/feature/checkout/presentation/bloc/checkout_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockCheckoutRepository extends Mock implements CheckoutRepository {}

class _MockMeRepository extends Mock implements MeRepository {}

class _MockCartCubit extends Mock implements CartCubit {}

Future<List<CheckoutState>> _collectStates(
  CheckoutBloc bloc,
  CheckoutEvent event,
) async {
  final states = <CheckoutState>[];
  final sub = bloc.stream.listen(states.add);
  bloc.add(event);
  await Future<void>.delayed(Duration.zero);
  await sub.cancel();
  return states;
}

const _kFees = OrderFees(subtotal: 100, shipping: 10, total: 110);
const _kQuote = CheckoutQuote(
  addressId: 'addr1',
  fees: _kFees,
  shipmentType: 'standard',
);
const _kAddress = Address(
  id: 'addr1',
  line1: '1 Marina Gate',
  city: 'Dubai',
  emirate: 'Dubai',
  isDefault: true,
);
const _kPayment = PaymentSheetData(
  clientSecret: 'sk_1',
  ephemeralKey: 'ek_1',
  customerId: 'cus_1',
  publishableKey: 'pk_1',
);
const _kOrderSummary = OrderSummary(
  orderId: 'order1',
  items: <CartItem>[],
  fees: _kFees,
);
const _kResult = CheckoutResult(order: _kOrderSummary, payment: _kPayment);

void main() {
  late _MockCheckoutRepository mockCheckout;
  late _MockMeRepository mockMe;
  late _MockCartCubit mockCubit;
  late CheckoutBloc bloc;

  setUp(() {
    mockCheckout = _MockCheckoutRepository();
    mockMe = _MockMeRepository();
    mockCubit = _MockCartCubit();
    when(() => mockCubit.state).thenReturn(Cart.empty);
    when(() => mockCubit.load()).thenAnswer((_) async {});
    bloc = CheckoutBloc(mockCheckout, mockMe, mockCubit);
  });

  tearDown(() => bloc.close());

  test('initial state is CheckoutLoadingState', () {
    expect(bloc.state, const CheckoutLoadingState());
  });

  group('CheckoutStarted', () {
    test('emits [loading, ready] on success', () async {
      when(
        () => mockMe.getAddresses(),
      ).thenAnswer((_) async => const <Address>[_kAddress]);
      when(
        () => mockCheckout.quote(any(), addressId: any(named: 'addressId')),
      ).thenAnswer((_) async => _kQuote);

      final states = await _collectStates(
        bloc,
        const CheckoutStarted('seller1'),
      );

      expect(states.first, const CheckoutLoadingState());
      final ready = states.last as CheckoutReadyState;
      expect(ready.quote, _kQuote);
      expect(ready.selectedAddressId, 'addr1'); // default address
      expect(ready.selectedShipmentType, 'standard');
    });

    test('proceeds with empty addresses when getAddresses throws', () async {
      when(() => mockMe.getAddresses()).thenThrow(Exception('network'));
      when(
        () => mockCheckout.quote(any(), addressId: any(named: 'addressId')),
      ).thenAnswer((_) async => _kQuote);

      final states = await _collectStates(
        bloc,
        const CheckoutStarted('seller1'),
      );

      final ready = states.last as CheckoutReadyState;
      expect(ready.addresses, isEmpty);
      expect(ready.selectedAddressId, isNull);
    });

    test('emits [loading, error] when quote throws', () async {
      when(
        () => mockMe.getAddresses(),
      ).thenAnswer((_) async => const <Address>[]);
      when(
        () => mockCheckout.quote(any(), addressId: any(named: 'addressId')),
      ).thenThrow(Exception('server'));

      final states = await _collectStates(
        bloc,
        const CheckoutStarted('seller1'),
      );

      expect(states.first, const CheckoutLoadingState());
      expect(states.last, isA<CheckoutErrorState>());
    });
  });

  group('CheckoutAddressSelected', () {
    Future<void> startCheckout() async {
      when(
        () => mockMe.getAddresses(),
      ).thenAnswer((_) async => const <Address>[_kAddress]);
      when(
        () => mockCheckout.quote(any(), addressId: any(named: 'addressId')),
      ).thenAnswer((_) async => _kQuote);
      final sub = bloc.stream.listen((_) {});
      bloc.add(const CheckoutStarted('seller1'));
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
    }

    test('emits [ready(isQuoting=true), ready(updated)] on success', () async {
      await startCheckout();
      const newQuote = CheckoutQuote(
        addressId: 'addr2',
        fees: _kFees,
        shipmentType: 'express',
      );
      when(
        () => mockCheckout.quote(any(), addressId: 'addr2'),
      ).thenAnswer((_) async => newQuote);

      final states = await _collectStates(
        bloc,
        const CheckoutAddressSelected('addr2'),
      );

      expect((states.first as CheckoutReadyState).isQuoting, isTrue);
      final last = states.last as CheckoutReadyState;
      expect(last.selectedAddressId, 'addr2');
      expect(last.isQuoting, isFalse);
      expect(last.quote, newQuote);
    });

    test('settles isQuoting=false on error', () async {
      await startCheckout();
      when(
        () => mockCheckout.quote(any(), addressId: any(named: 'addressId')),
      ).thenThrow(Exception('network'));

      final states = await _collectStates(
        bloc,
        const CheckoutAddressSelected('addr2'),
      );

      final last = states.last as CheckoutReadyState;
      expect(last.isQuoting, isFalse);
    });
  });

  group('CheckoutShipmentSelected', () {
    Future<void> startCheckout() async {
      when(
        () => mockMe.getAddresses(),
      ).thenAnswer((_) async => const <Address>[]);
      when(
        () => mockCheckout.quote(any(), addressId: any(named: 'addressId')),
      ).thenAnswer((_) async => _kQuote);
      final sub = bloc.stream.listen((_) {});
      bloc.add(const CheckoutStarted('seller1'));
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
    }

    test('updates selected shipment type', () async {
      await startCheckout();

      final states = await _collectStates(
        bloc,
        const CheckoutShipmentSelected('express'),
      );

      final ready = states.last as CheckoutReadyState;
      expect(ready.selectedShipmentType, 'express');
    });
  });

  group('CheckoutPayRequested', () {
    Future<void> startCheckout() async {
      when(
        () => mockMe.getAddresses(),
      ).thenAnswer((_) async => const <Address>[_kAddress]);
      when(
        () => mockCheckout.quote(any(), addressId: any(named: 'addressId')),
      ).thenAnswer((_) async => _kQuote);
      final sub = bloc.stream.listen((_) {});
      bloc.add(const CheckoutStarted('seller1'));
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
    }

    test('emits [ready(isCreating=true), payment] on success', () async {
      await startCheckout();
      when(
        () => mockCheckout.checkout(
          any(),
          addressId: any(named: 'addressId'),
          shipmentType: any(named: 'shipmentType'),
        ),
      ).thenAnswer((_) async => _kResult);

      final states = await _collectStates(bloc, const CheckoutPayRequested());

      expect((states.first as CheckoutReadyState).isCreating, isTrue);
      expect(states.last, isA<CheckoutPaymentState>());
      final payment = states.last as CheckoutPaymentState;
      expect(payment.result, _kResult);
    });

    test(
      'emits [ready(isCreating=true), ready(payError)] on failure',
      () async {
        await startCheckout();
        when(
          () => mockCheckout.checkout(
            any(),
            addressId: any(named: 'addressId'),
            shipmentType: any(named: 'shipmentType'),
          ),
        ).thenThrow(Exception('payment declined'));

        final states = await _collectStates(bloc, const CheckoutPayRequested());

        final last = states.last as CheckoutReadyState;
        expect(last.payError, isNotNull);
      },
    );
  });

  group('CheckoutPaid', () {
    Future<void> startAndPay() async {
      when(
        () => mockMe.getAddresses(),
      ).thenAnswer((_) async => const <Address>[_kAddress]);
      when(
        () => mockCheckout.quote(any(), addressId: any(named: 'addressId')),
      ).thenAnswer((_) async => _kQuote);
      when(
        () => mockCheckout.checkout(
          any(),
          addressId: any(named: 'addressId'),
          shipmentType: any(named: 'shipmentType'),
        ),
      ).thenAnswer((_) async => _kResult);

      final sub = bloc.stream.listen((_) {});
      bloc.add(const CheckoutStarted('seller1'));
      await Future<void>.delayed(Duration.zero);
      bloc.add(const CheckoutPayRequested());
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
    }

    test('emits CheckoutDoneState and refreshes cart', () async {
      await startAndPay();

      final states = await _collectStates(bloc, const CheckoutPaid());

      final done = states.last as CheckoutDoneState;
      expect(done.orderId, 'order1');
      verify(() => mockCubit.load()).called(1);
    });
  });

  group('CheckoutPayCancelled', () {
    Future<void> startAndPay() async {
      when(
        () => mockMe.getAddresses(),
      ).thenAnswer((_) async => const <Address>[_kAddress]);
      when(
        () => mockCheckout.quote(any(), addressId: any(named: 'addressId')),
      ).thenAnswer((_) async => _kQuote);
      when(
        () => mockCheckout.checkout(
          any(),
          addressId: any(named: 'addressId'),
          shipmentType: any(named: 'shipmentType'),
        ),
      ).thenAnswer((_) async => _kResult);

      final sub = bloc.stream.listen((_) {});
      bloc.add(const CheckoutStarted('seller1'));
      await Future<void>.delayed(Duration.zero);
      bloc.add(const CheckoutPayRequested());
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
    }

    test('returns to ready state when payment is cancelled', () async {
      await startAndPay();

      final states = await _collectStates(bloc, const CheckoutPayCancelled());

      expect(states.last, isA<CheckoutReadyState>());
    });
  });
}
