import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/domain/cart/entity/cart.dart';
import 'package:klozy/src/feature/cart/presentation/bloc/cart_event.dart';
import 'package:klozy/src/feature/cart/presentation/bloc/cart_state.dart';

void main() {
  group('CartEvent', () {
    group('CartStarted', () {
      test('props is empty', () {
        expect(const CartStarted().props, isEmpty);
      });

      test('two instances are equal', () {
        expect(const CartStarted(), const CartStarted());
      });
    });

    group('CartItemRemoved', () {
      test('stores productId', () {
        const event = CartItemRemoved('p1');
        expect(event.productId, 'p1');
      });

      test('props contains productId', () {
        expect(const CartItemRemoved('p1').props, ['p1']);
      });

      test('equal when same productId', () {
        expect(const CartItemRemoved('p1'), const CartItemRemoved('p1'));
      });

      test('not equal for different productId', () {
        expect(
          const CartItemRemoved('p1'),
          isNot(equals(const CartItemRemoved('p2'))),
        );
      });
    });

    group('CartOfferMade', () {
      test('stores productIds and amount', () {
        const event = CartOfferMade(productIds: ['a', 'b'], amount: 200);
        expect(event.productIds, ['a', 'b']);
        expect(event.amount, 200);
      });

      test('props contains productIds and amount', () {
        const event = CartOfferMade(productIds: ['x'], amount: 50);
        expect(event.props, [
          ['x'],
          50,
        ]);
      });

      test('equal when same values', () {
        expect(
          const CartOfferMade(productIds: ['p'], amount: 100),
          const CartOfferMade(productIds: ['p'], amount: 100),
        );
      });

      test('not equal for different amount', () {
        expect(
          const CartOfferMade(productIds: ['p'], amount: 100),
          isNot(equals(const CartOfferMade(productIds: ['p'], amount: 200))),
        );
      });
    });

    group('CartOfferCancelled', () {
      test('stores offerId', () {
        const event = CartOfferCancelled('offer1');
        expect(event.offerId, 'offer1');
      });

      test('props contains offerId', () {
        expect(const CartOfferCancelled('offer1').props, ['offer1']);
      });

      test('equal when same offerId', () {
        expect(
          const CartOfferCancelled('offer1'),
          const CartOfferCancelled('offer1'),
        );
      });

      test('not equal for different offerId', () {
        expect(
          const CartOfferCancelled('offer1'),
          isNot(equals(const CartOfferCancelled('offer2'))),
        );
      });
    });
  });

  group('CartState', () {
    group('CartLoadingState', () {
      test('props is empty', () {
        expect(const CartLoadingState().props, isEmpty);
      });

      test('two instances are equal', () {
        expect(const CartLoadingState(), const CartLoadingState());
      });
    });

    group('CartErrorState', () {
      test('stores error type', () {
        const state = CartErrorState(type: AppErrorType.network);
        expect(state.type, AppErrorType.network);
      });

      test('props contains type', () {
        expect(const CartErrorState(type: AppErrorType.server).props, [
          AppErrorType.server,
        ]);
      });

      test('equal when same type', () {
        expect(
          const CartErrorState(type: AppErrorType.unknown),
          const CartErrorState(type: AppErrorType.unknown),
        );
      });

      test('not equal for different type', () {
        expect(
          const CartErrorState(type: AppErrorType.network),
          isNot(equals(const CartErrorState(type: AppErrorType.server))),
        );
      });
    });

    group('CartLoadedState', () {
      test('stores cart with isMutating defaulting to false', () {
        const state = CartLoadedState(Cart.empty);
        expect(state.cart, Cart.empty);
        expect(state.isMutating, isFalse);
      });

      test('stores isMutating=true when provided', () {
        const state = CartLoadedState(Cart.empty, isMutating: true);
        expect(state.isMutating, isTrue);
      });

      test('props contains cart and isMutating', () {
        const state = CartLoadedState(Cart.empty, isMutating: false);
        expect(state.props, [Cart.empty, false]);
      });

      test('equal when same cart and isMutating', () {
        expect(
          const CartLoadedState(Cart.empty),
          const CartLoadedState(Cart.empty),
        );
      });

      test('not equal when isMutating differs', () {
        expect(
          const CartLoadedState(Cart.empty, isMutating: true),
          isNot(equals(const CartLoadedState(Cart.empty, isMutating: false))),
        );
      });
    });
  });
}
