import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/orders/entity/order_action.dart';

void main() {
  group('OrderAction.fromApi', () {
    test('returns empty set for null input', () {
      expect(OrderAction.fromApi(null), isEmpty);
    });

    test('returns empty set for empty list', () {
      expect(OrderAction.fromApi(<dynamic>[]), isEmpty);
    });

    test('maps ship action', () {
      expect(
        OrderAction.fromApi(<dynamic>['ship']),
        contains(OrderAction.ship),
      );
      expect(
        OrderAction.fromApi(<dynamic>['SHIP_ORDER']),
        contains(OrderAction.ship),
      );
    });

    test('maps confirmReceipt action', () {
      expect(
        OrderAction.fromApi(<dynamic>['confirmReceipt']),
        contains(OrderAction.confirmReceipt),
      );
      expect(
        OrderAction.fromApi(<dynamic>['CONFIRM_RECEIPT']),
        contains(OrderAction.confirmReceipt),
      );
    });

    test('maps reportProblem action', () {
      expect(
        OrderAction.fromApi(<dynamic>['reportProblem']),
        contains(OrderAction.reportProblem),
      );
      expect(
        OrderAction.fromApi(<dynamic>['REPORT']),
        contains(OrderAction.reportProblem),
      );
    });

    test('maps cancel action', () {
      expect(
        OrderAction.fromApi(<dynamic>['cancel']),
        contains(OrderAction.cancel),
      );
      expect(
        OrderAction.fromApi(<dynamic>['CANCEL']),
        contains(OrderAction.cancel),
      );
    });

    test('maps review action', () {
      expect(
        OrderAction.fromApi(<dynamic>['review']),
        contains(OrderAction.review),
      );
      expect(
        OrderAction.fromApi(<dynamic>['REVIEW_SELLER']),
        contains(OrderAction.review),
      );
    });

    test('multiple actions in one list', () {
      final Set<OrderAction> actions = OrderAction.fromApi(<dynamic>[
        'ship',
        'cancel',
        'review',
      ]);
      expect(
        actions,
        containsAll(<OrderAction>[
          OrderAction.ship,
          OrderAction.cancel,
          OrderAction.review,
        ]),
      );
    });

    test('ignores non-string entries', () {
      final Set<OrderAction> actions = OrderAction.fromApi(<dynamic>[
        42,
        null,
        true,
      ]);
      expect(actions, isEmpty);
    });

    test('unknown token does not add any action', () {
      final Set<OrderAction> actions = OrderAction.fromApi(<dynamic>['foobar']);
      expect(actions, isEmpty);
    });
  });

  group('OrderRole', () {
    test('has buyer and seller values', () {
      expect(OrderRole.values, contains(OrderRole.buyer));
      expect(OrderRole.values, contains(OrderRole.seller));
    });
  });

  group('OrderListState', () {
    test('has inProgress and completed values', () {
      expect(OrderListState.values, contains(OrderListState.inProgress));
      expect(OrderListState.values, contains(OrderListState.completed));
    });
  });
}
