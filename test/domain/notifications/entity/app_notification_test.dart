import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/notifications/entity/app_notification.dart';
import 'package:klozy/src/domain/notifications/entity/notification_type.dart';

void main() {
  final DateTime ts = DateTime(2024, 6, 1, 12);

  group('AppNotification', () {
    final AppNotification full = AppNotification(
      id: 'n1',
      type: NotificationType.newOrder,
      title: 'New order!',
      body: 'You have a new order.',
      read: false,
      createdAt: ts,
      productId: 'prod-1',
      orderId: 'ord-1',
      userId: 'usr-1',
      conversationId: 'conv-1',
    );

    test('getters return constructor values', () {
      expect(full.id, 'n1');
      expect(full.type, NotificationType.newOrder);
      expect(full.title, 'New order!');
      expect(full.body, 'You have a new order.');
      expect(full.read, isFalse);
      expect(full.createdAt, ts);
      expect(full.productId, 'prod-1');
      expect(full.orderId, 'ord-1');
      expect(full.userId, 'usr-1');
      expect(full.conversationId, 'conv-1');
    });

    test('optional fields default to empty / null / false', () {
      const AppNotification minimal = AppNotification(
        id: 'n2',
        type: NotificationType.unknown,
      );
      expect(minimal.title, '');
      expect(minimal.body, '');
      expect(minimal.read, isFalse);
      expect(minimal.createdAt, isNull);
      expect(minimal.productId, isNull);
      expect(minimal.orderId, isNull);
      expect(minimal.userId, isNull);
      expect(minimal.conversationId, isNull);
    });

    test('two instances with same fields are equal', () {
      final AppNotification other = AppNotification(
        id: 'n1',
        type: NotificationType.newOrder,
        title: 'New order!',
        body: 'You have a new order.',
        read: false,
        createdAt: ts,
        productId: 'prod-1',
        orderId: 'ord-1',
        userId: 'usr-1',
        conversationId: 'conv-1',
      );
      expect(full, equals(other));
      expect(full.hashCode, equals(other.hashCode));
    });

    test('instances with different id are not equal', () {
      const AppNotification other = AppNotification(
        id: 'n99',
        type: NotificationType.unknown,
      );
      expect(full, isNot(equals(other)));
    });

    test('copyWith changes read', () {
      final AppNotification updated = full.copyWith(read: true);
      expect(updated.read, isTrue);
      expect(updated.id, full.id);
      expect(updated.type, full.type);
    });

    test('copyWith with no args preserves all fields', () {
      final AppNotification updated = full.copyWith();
      expect(updated, equals(full));
    });
  });
}
