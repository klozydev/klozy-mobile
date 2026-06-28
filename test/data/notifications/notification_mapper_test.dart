import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/data/notifications/notification_mapper.dart';
import 'package:klozy/src/domain/notifications/entity/notification_type.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Map<String, dynamic> _base({
  String id = 'notif-1',
  String type = 'newOffer',
  String title = 'New offer',
  String body = 'You received an offer',
  bool read = false,
  String? createdAt = '2024-05-01T08:00:00.000Z',
  Map<String, dynamic>? data,
}) => <String, dynamic>{
  'id': id,
  'type': type,
  'title': title,
  'body': body,
  'read': read,
  if (createdAt != null) 'createdAt': createdAt,
  if (data != null) 'data': data,
};

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // Null / empty input
  // -------------------------------------------------------------------------

  group('mapNotification — null/empty input', () {
    test('null returns safe defaults', () {
      final n = mapNotification(null);
      expect(n.id, isEmpty);
      expect(n.type, NotificationType.unknown);
      expect(n.title, isEmpty);
      expect(n.body, isEmpty);
      expect(n.read, isFalse);
      expect(n.createdAt, isNull);
      expect(n.productId, isNull);
      expect(n.orderId, isNull);
      expect(n.userId, isNull);
      expect(n.conversationId, isNull);
    });

    test('empty map returns safe defaults', () {
      final n = mapNotification(const <String, dynamic>{});
      expect(n.id, isEmpty);
      expect(n.type, NotificationType.unknown);
    });
  });

  // -------------------------------------------------------------------------
  // Standard fields
  // -------------------------------------------------------------------------

  group('mapNotification — standard fields', () {
    late final dynamic n;
    setUpAll(() => n = mapNotification(_base()));

    test('id', () => expect(n.id, 'notif-1'));
    test('type', () => expect(n.type, NotificationType.newOffer));
    test('title', () => expect(n.title, 'New offer'));
    test('body', () => expect(n.body, 'You received an offer'));
    test('read false', () => expect(n.read, isFalse));
    test('createdAt parsed', () => expect(n.createdAt, isNotNull));
    test('createdAt year', () => expect(n.createdAt!.year, 2024));
  });

  // -------------------------------------------------------------------------
  // id alternatives
  // -------------------------------------------------------------------------

  group('mapNotification — id alternatives', () {
    test('reads _id when id absent', () {
      final raw = Map<String, dynamic>.from(_base())
        ..remove('id')
        ..['_id'] = 'alt-notif';
      expect(mapNotification(raw).id, 'alt-notif');
    });
  });

  // -------------------------------------------------------------------------
  // read flag
  // -------------------------------------------------------------------------

  group('mapNotification — read flag', () {
    test('read: true', () {
      final n = mapNotification(_base(read: true));
      expect(n.read, isTrue);
    });

    test('isRead: true alternative', () {
      final raw = <String, dynamic>{..._base(), 'isRead': true}..remove('read');
      expect(mapNotification(raw).read, isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // createdAt
  // -------------------------------------------------------------------------

  group('mapNotification — createdAt', () {
    test('null when absent', () {
      final n = mapNotification(_base(createdAt: null));
      expect(n.createdAt, isNull);
    });

    test('invalid date → null', () {
      final raw = <String, dynamic>{..._base(), 'createdAt': 'not-a-date'};
      expect(mapNotification(raw).createdAt, isNull);
    });

    test('created key alternative', () {
      final raw = Map<String, dynamic>.from(_base())
        ..remove('createdAt')
        ..['created'] = '2024-07-01T00:00:00.000Z';
      final n = mapNotification(raw);
      expect(n.createdAt, isNotNull);
      expect(n.createdAt!.year, 2024);
    });
  });

  // -------------------------------------------------------------------------
  // body alternatives
  // -------------------------------------------------------------------------

  group('mapNotification — body alternatives', () {
    test('message key used when body empty', () {
      final raw = <String, dynamic>{
        ..._base(),
        'body': '',
        'message': 'A message',
      };
      expect(mapNotification(raw).body, 'A message');
    });
  });

  // -------------------------------------------------------------------------
  // data sub-object for contextual ids
  // -------------------------------------------------------------------------

  group('mapNotification — data sub-object', () {
    test('productId from data.productId', () {
      final n = mapNotification(
        _base(data: <String, dynamic>{'productId': 'prod-42'}),
      );
      expect(n.productId, 'prod-42');
    });

    test('orderId from data.orderId', () {
      final n = mapNotification(
        _base(data: <String, dynamic>{'orderId': 'ord-7'}),
      );
      expect(n.orderId, 'ord-7');
    });

    test('userId from data.userId', () {
      final n = mapNotification(
        _base(data: <String, dynamic>{'userId': 'u-99'}),
      );
      expect(n.userId, 'u-99');
    });

    test('userId from data.actorId', () {
      final n = mapNotification(
        _base(data: <String, dynamic>{'actorId': 'actor-1'}),
      );
      expect(n.userId, 'actor-1');
    });

    test('conversationId from data.conversationId', () {
      final n = mapNotification(
        _base(data: <String, dynamic>{'conversationId': 'conv-5'}),
      );
      expect(n.conversationId, 'conv-5');
    });
  });

  // -------------------------------------------------------------------------
  // contextual ids fall back to top-level keys
  // -------------------------------------------------------------------------

  group('mapNotification — top-level contextual id fallbacks', () {
    test('productId from top-level productId', () {
      final raw = <String, dynamic>{..._base(), 'productId': 'p-top'};
      expect(mapNotification(raw).productId, 'p-top');
    });

    test('orderId from top-level orderId', () {
      final raw = <String, dynamic>{..._base(), 'orderId': 'o-top'};
      expect(mapNotification(raw).orderId, 'o-top');
    });

    test('userId from top-level userId', () {
      final raw = <String, dynamic>{..._base(), 'userId': 'u-top'};
      expect(mapNotification(raw).userId, 'u-top');
    });

    test('conversationId from top-level conversationId', () {
      final raw = <String, dynamic>{..._base(), 'conversationId': 'cv-top'};
      expect(mapNotification(raw).conversationId, 'cv-top');
    });

    test('data.productId takes precedence over top-level', () {
      final raw = <String, dynamic>{
        ..._base(data: <String, dynamic>{'productId': 'data-prod'}),
        'productId': 'top-prod',
      };
      expect(mapNotification(raw).productId, 'data-prod');
    });
  });

  // -------------------------------------------------------------------------
  // NotificationType.fromApi — all branches
  // -------------------------------------------------------------------------

  group('NotificationType.fromApi — all variants', () {
    for (final entry in <String, NotificationType>{
      'newReview': NotificationType.newReview,
      'offerAccepted': NotificationType.offerAccepted,
      'offerRefused': NotificationType.offerRefused,
      'offerDeclined': NotificationType.offerRefused,
      'newOffer': NotificationType.newOffer,
      'inDelivery': NotificationType.inDelivery,
      'delivered': NotificationType.delivered,
      'newOrder': NotificationType.newOrder,
      'shippingReminder': NotificationType.shippingReminder,
      'newFollower': NotificationType.newFollower,
      'priceDrop': NotificationType.priceDrop,
      'something_unknown': NotificationType.unknown,
    }.entries) {
      test('${entry.key} → ${entry.value.name}', () {
        final raw = <String, dynamic>{..._base(), 'type': entry.key};
        expect(mapNotification(raw).type, entry.value);
      });
    }
  });
}
