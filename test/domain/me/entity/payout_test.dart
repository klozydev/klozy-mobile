import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/me/entity/payout.dart';

void main() {
  final DateTime ts = DateTime(2024, 3, 10);

  group('PayoutItem', () {
    final PayoutItem item = PayoutItem(
      orderId: 'ord-1',
      grossFils: 2000,
      commissionFils: 200,
      netFils: 1800,
      status: PayoutStatus.completed,
      method: PayoutMethod.iban,
      createdAt: ts,
    );

    test('getters return constructor values', () {
      expect(item.orderId, 'ord-1');
      expect(item.grossFils, 2000);
      expect(item.commissionFils, 200);
      expect(item.netFils, 1800);
      expect(item.status, PayoutStatus.completed);
      expect(item.method, PayoutMethod.iban);
      expect(item.createdAt, ts);
    });

    test('optional fields default to zero / pending / unknown', () {
      const PayoutItem minimal = PayoutItem(orderId: 'ord-2');
      expect(minimal.grossFils, 0);
      expect(minimal.commissionFils, 0);
      expect(minimal.netFils, 0);
      expect(minimal.status, PayoutStatus.pending);
      expect(minimal.method, PayoutMethod.unknown);
      expect(minimal.createdAt, isNull);
    });

    test('two instances with same fields are equal', () {
      final PayoutItem other = PayoutItem(
        orderId: 'ord-1',
        grossFils: 2000,
        commissionFils: 200,
        netFils: 1800,
        status: PayoutStatus.completed,
        method: PayoutMethod.iban,
        createdAt: ts,
      );
      expect(item, equals(other));
      expect(item.hashCode, equals(other.hashCode));
    });

    test('instances with different orderId are not equal', () {
      const PayoutItem other = PayoutItem(orderId: 'ord-X');
      expect(item, isNot(equals(other)));
    });
  });

  group('PayoutSummary', () {
    const PayoutItem item = PayoutItem(orderId: 'ord-1', netFils: 1800);
    late PayoutSummary summary;

    setUp(() {
      summary = const PayoutSummary(
        pendingFils: 500,
        lifetimePaidFils: 10000,
        items: <PayoutItem>[item],
      );
    });

    test('getters return constructor values', () {
      expect(summary.pendingFils, 500);
      expect(summary.lifetimePaidFils, 10000);
      expect(summary.items, <PayoutItem>[item]);
    });

    test('defaults to zero and empty list', () {
      const PayoutSummary empty = PayoutSummary();
      expect(empty.pendingFils, 0);
      expect(empty.lifetimePaidFils, 0);
      expect(empty.items, isEmpty);
    });

    test('two instances with same fields are equal', () {
      const PayoutSummary other = PayoutSummary(
        pendingFils: 500,
        lifetimePaidFils: 10000,
        items: <PayoutItem>[item],
      );
      expect(summary, equals(other));
      expect(summary.hashCode, equals(other.hashCode));
    });
  });
}
