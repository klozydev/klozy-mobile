import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/domain/cart/entity/cart_item.dart';
import 'package:klozy/src/domain/checkout/entity/checkout_quote.dart';
import 'package:klozy/src/domain/checkout/entity/checkout_result.dart';
import 'package:klozy/src/domain/checkout/entity/order_fees.dart';
import 'package:klozy/src/domain/checkout/entity/order_summary.dart';
import 'package:klozy/src/domain/checkout/entity/payment_sheet_data.dart';
import 'package:klozy/src/domain/me/entity/address.dart';
import 'package:klozy/src/feature/checkout/presentation/bloc/checkout_event.dart';
import 'package:klozy/src/feature/checkout/presentation/bloc/checkout_state.dart';

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
  group('CheckoutEvent', () {
    group('CheckoutStarted', () {
      test('stores sellerId', () {
        const event = CheckoutStarted('seller1');
        expect(event.sellerId, 'seller1');
      });

      test('props contains sellerId', () {
        expect(const CheckoutStarted('seller1').props, ['seller1']);
      });

      test('equal when same sellerId', () {
        expect(const CheckoutStarted('s1'), const CheckoutStarted('s1'));
      });

      test('not equal for different sellerId', () {
        expect(
          const CheckoutStarted('s1'),
          isNot(equals(const CheckoutStarted('s2'))),
        );
      });
    });

    group('CheckoutAddressSelected', () {
      test('stores addressId', () {
        const event = CheckoutAddressSelected('addr1');
        expect(event.addressId, 'addr1');
      });

      test('props contains addressId', () {
        expect(const CheckoutAddressSelected('addr1').props, ['addr1']);
      });

      test('equal when same addressId', () {
        expect(
          const CheckoutAddressSelected('a1'),
          const CheckoutAddressSelected('a1'),
        );
      });

      test('not equal for different addressId', () {
        expect(
          const CheckoutAddressSelected('a1'),
          isNot(equals(const CheckoutAddressSelected('a2'))),
        );
      });
    });

    group('CheckoutShipmentSelected', () {
      test('stores shipmentType', () {
        const event = CheckoutShipmentSelected('express');
        expect(event.shipmentType, 'express');
      });

      test('props contains shipmentType', () {
        expect(const CheckoutShipmentSelected('express').props, ['express']);
      });

      test('equal when same shipmentType', () {
        expect(
          const CheckoutShipmentSelected('express'),
          const CheckoutShipmentSelected('express'),
        );
      });

      test('not equal for different shipmentType', () {
        expect(
          const CheckoutShipmentSelected('standard'),
          isNot(equals(const CheckoutShipmentSelected('express'))),
        );
      });
    });

    group('CheckoutPayRequested', () {
      test('props is empty', () {
        expect(const CheckoutPayRequested().props, isEmpty);
      });

      test('two instances are equal', () {
        expect(const CheckoutPayRequested(), const CheckoutPayRequested());
      });
    });

    group('CheckoutPaid', () {
      test('props is empty', () {
        expect(const CheckoutPaid().props, isEmpty);
      });

      test('two instances are equal', () {
        expect(const CheckoutPaid(), const CheckoutPaid());
      });
    });

    group('CheckoutPayCancelled', () {
      test('props is empty', () {
        expect(const CheckoutPayCancelled().props, isEmpty);
      });

      test('two instances are equal', () {
        expect(const CheckoutPayCancelled(), const CheckoutPayCancelled());
      });
    });
  });

  group('CheckoutState', () {
    group('CheckoutLoadingState', () {
      test('props is empty', () {
        expect(const CheckoutLoadingState().props, isEmpty);
      });

      test('two instances are equal', () {
        expect(const CheckoutLoadingState(), const CheckoutLoadingState());
      });
    });

    group('CheckoutErrorState', () {
      test('stores type', () {
        const state = CheckoutErrorState(type: AppErrorType.network);
        expect(state.type, AppErrorType.network);
      });

      test('message defaults to null', () {
        const state = CheckoutErrorState(type: AppErrorType.server);
        expect(state.message, isNull);
      });

      test('stores optional message', () {
        const state = CheckoutErrorState(
          type: AppErrorType.server,
          message: 'Item not available',
        );
        expect(state.message, 'Item not available');
      });

      test('props contains type and message', () {
        expect(
          const CheckoutErrorState(
            type: AppErrorType.server,
            message: 'err',
          ).props,
          [AppErrorType.server, 'err'],
        );
      });

      test('props with null message', () {
        expect(const CheckoutErrorState(type: AppErrorType.network).props, [
          AppErrorType.network,
          null,
        ]);
      });

      test('equal when same type and null message', () {
        expect(
          const CheckoutErrorState(type: AppErrorType.unknown),
          const CheckoutErrorState(type: AppErrorType.unknown),
        );
      });

      test('not equal when message differs', () {
        expect(
          const CheckoutErrorState(type: AppErrorType.server, message: 'a'),
          isNot(
            equals(
              const CheckoutErrorState(type: AppErrorType.server, message: 'b'),
            ),
          ),
        );
      });
    });

    group('CheckoutReadyState', () {
      test('default nullable fields are null', () {
        const state = CheckoutReadyState(addresses: [], quote: _kQuote);
        expect(state.selectedAddressId, isNull);
        expect(state.selectedShipmentType, isNull);
        expect(state.isQuoting, isFalse);
        expect(state.isCreating, isFalse);
        expect(state.payError, isNull);
      });

      test('stores all fields', () {
        const state = CheckoutReadyState(
          addresses: [_kAddress],
          quote: _kQuote,
          selectedAddressId: 'addr1',
          selectedShipmentType: 'express',
          isQuoting: true,
          isCreating: true,
          payError: 'Payment failed',
        );
        expect(state.addresses, [_kAddress]);
        expect(state.quote, _kQuote);
        expect(state.selectedAddressId, 'addr1');
        expect(state.selectedShipmentType, 'express');
        expect(state.isQuoting, isTrue);
        expect(state.isCreating, isTrue);
        expect(state.payError, 'Payment failed');
      });

      test('props contains all seven fields in order', () {
        const state = CheckoutReadyState(
          addresses: [_kAddress],
          quote: _kQuote,
          selectedAddressId: 'addr1',
          selectedShipmentType: 'standard',
        );
        expect(state.props, [
          [_kAddress],
          'addr1',
          _kQuote,
          'standard',
          false,
          false,
          null,
        ]);
      });

      group('effectiveFees', () {
        test('returns quote fees when selectedShipmentType is null', () {
          const state = CheckoutReadyState(addresses: [], quote: _kQuote);
          expect(state.effectiveFees, _kFees);
        });

        test(
          'returns quote fees when selectedShipmentType matches quote type',
          () {
            const state = CheckoutReadyState(
              addresses: [],
              quote: _kQuote,
              selectedShipmentType: 'standard',
            );
            expect(state.effectiveFees, _kFees);
          },
        );

        test('returns feesFor the matching shipping option', () {
          const expressOption = ShippingOption(
            shipmentType: 'express',
            amount: 25,
          );
          const quoteWithOptions = CheckoutQuote(
            fees: _kFees,
            shipmentType: 'standard',
            shippingOptions: [expressOption],
          );
          const state = CheckoutReadyState(
            addresses: [],
            quote: quoteWithOptions,
            selectedShipmentType: 'express',
          );
          expect(state.effectiveFees.shipping, 25);
          expect(state.effectiveFees.subtotal, _kFees.subtotal);
        });

        test(
          'falls back to quote fees when type not found in shippingOptions',
          () {
            const state = CheckoutReadyState(
              addresses: [],
              quote: _kQuote,
              selectedShipmentType: 'unknown-type',
            );
            expect(state.effectiveFees, _kFees);
          },
        );
      });

      group('copyWith', () {
        test('updates quote', () {
          const state = CheckoutReadyState(
            addresses: [_kAddress],
            quote: _kQuote,
          );
          const newQuote = CheckoutQuote(fees: _kFees, shipmentType: 'express');
          final updated = state.copyWith(quote: newQuote);
          expect(updated.quote, newQuote);
          expect(updated.addresses, [_kAddress]);
        });

        test('updates selectedAddressId', () {
          const state = CheckoutReadyState(
            addresses: [],
            quote: _kQuote,
            selectedAddressId: 'addr1',
          );
          final updated = state.copyWith(selectedAddressId: 'addr2');
          expect(updated.selectedAddressId, 'addr2');
        });

        test('updates selectedShipmentType', () {
          const state = CheckoutReadyState(addresses: [], quote: _kQuote);
          final updated = state.copyWith(selectedShipmentType: 'express');
          expect(updated.selectedShipmentType, 'express');
        });

        test('updates isQuoting to true', () {
          const state = CheckoutReadyState(addresses: [], quote: _kQuote);
          final updated = state.copyWith(isQuoting: true);
          expect(updated.isQuoting, isTrue);
        });

        test('updates isCreating to true', () {
          const state = CheckoutReadyState(addresses: [], quote: _kQuote);
          final updated = state.copyWith(isCreating: true);
          expect(updated.isCreating, isTrue);
        });

        test('sets payError', () {
          const state = CheckoutReadyState(addresses: [], quote: _kQuote);
          final updated = state.copyWith(payError: 'Payment failed');
          expect(updated.payError, 'Payment failed');
        });

        test('payError is null when not passed to copyWith', () {
          const state = CheckoutReadyState(
            addresses: [],
            quote: _kQuote,
            payError: 'old error',
          );
          final updated = state.copyWith();
          expect(updated.payError, isNull);
        });

        test('preserves existing values when nothing is passed', () {
          const state = CheckoutReadyState(
            addresses: [_kAddress],
            quote: _kQuote,
            selectedAddressId: 'addr1',
            selectedShipmentType: 'express',
            isQuoting: false,
            isCreating: false,
          );
          final updated = state.copyWith();
          expect(updated.addresses, [_kAddress]);
          expect(updated.quote, _kQuote);
          expect(updated.selectedAddressId, 'addr1');
          expect(updated.selectedShipmentType, 'express');
          expect(updated.isQuoting, isFalse);
          expect(updated.isCreating, isFalse);
        });
      });
    });

    group('CheckoutPaymentState', () {
      test('stores result', () {
        const state = CheckoutPaymentState(_kResult);
        expect(state.result, _kResult);
      });

      test('props contains result', () {
        expect(const CheckoutPaymentState(_kResult).props, [_kResult]);
      });

      test('equal when same result', () {
        expect(
          const CheckoutPaymentState(_kResult),
          const CheckoutPaymentState(_kResult),
        );
      });
    });

    group('CheckoutDoneState', () {
      test('stores orderId', () {
        const state = CheckoutDoneState('order1');
        expect(state.orderId, 'order1');
      });

      test('props contains orderId', () {
        expect(const CheckoutDoneState('order1').props, ['order1']);
      });

      test('equal when same orderId', () {
        expect(
          const CheckoutDoneState('order1'),
          const CheckoutDoneState('order1'),
        );
      });

      test('not equal for different orderId', () {
        expect(
          const CheckoutDoneState('order1'),
          isNot(equals(const CheckoutDoneState('order2'))),
        );
      });
    });
  });
}
