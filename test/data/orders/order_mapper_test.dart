import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/data/orders/order_mapper.dart';
import 'package:klozy/src/domain/orders/entity/order_action.dart';
import 'package:klozy/src/domain/orders/entity/order_status.dart';
import 'package:klozy/src/domain/orders/entity/order_tracking.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Map<String, dynamic> _baseItem({
  String id = 'p1',
  String title = 'Air Max',
  num price = 100,
  String? image = 'https://cdn.example.com/img.jpg',
}) => <String, dynamic>{
  'productId': id,
  'title': title,
  'brand': 'Nike',
  'size': '42',
  'image': image,
  'price': price,
};

Map<String, dynamic> _baseFees({
  num subtotal = 80,
  num shipping = 10,
  num protection = 5,
  num vat = 5,
  num total = 100,
}) => <String, dynamic>{
  'subtotal': subtotal,
  'shipping': shipping,
  'protection': protection,
  'vat': vat,
  'total': total,
};

Map<String, dynamic> _baseSeller({
  String id = 'seller-1',
  String name = 'Alice',
  bool isPro = true,
}) => <String, dynamic>{
  'id': id,
  'displayName': name,
  'avatarUrl': 'https://cdn.example.com/alice.jpg',
  'isPro': isPro,
};

Map<String, dynamic> _baseListItem({
  String role = 'buyer',
  List<Map<String, dynamic>>? items,
  Map<String, dynamic>? fees,
  Map<String, dynamic>? seller,
  String status = 'pending',
  String? createdAt,
}) => <String, dynamic>{
  'id': 'order-1',
  'viewerRole': role,
  'items': items ?? <dynamic>[_baseItem()],
  'fees': fees ?? _baseFees(),
  'seller': seller ?? _baseSeller(),
  'status': status,
  if (createdAt != null) 'createdAt': createdAt,
};

Map<String, dynamic> _baseOrderDetail({
  String role = 'buyer',
  String status = 'pending',
  List<String> actions = const <String>[],
  String? returnReason,
  Map<String, dynamic>? tracking,
  Map<String, dynamic>? deliveryAddress,
}) => <String, dynamic>{
  'id': 'order-99',
  'viewerRole': role,
  'status': status,
  'availableActions': actions,
  'items': <dynamic>[_baseItem()],
  'fees': _baseFees(),
  'seller': _baseSeller(),
  if (returnReason != null) 'returnReason': returnReason,
  if (tracking != null) 'tracking': tracking,
  if (deliveryAddress != null) 'deliveryAddress': deliveryAddress,
};

// ---------------------------------------------------------------------------
// mapOrderListItem
// ---------------------------------------------------------------------------

void main() {
  group('mapOrderListItem — null/empty input', () {
    test('null input returns safe defaults', () {
      final item = mapOrderListItem(null);
      expect(item.id, isEmpty);
      expect(item.title, isEmpty);
      expect(item.price, 0);
      expect(item.status, OrderStatus.unknown);
      expect(item.counterpartName, isEmpty);
    });

    test('empty map returns safe defaults', () {
      final item = mapOrderListItem(const <String, dynamic>{});
      expect(item.id, isEmpty);
    });
  });

  group('mapOrderListItem — standard fields', () {
    late final dynamic item;
    setUpAll(() => item = mapOrderListItem(_baseListItem()));

    test('id', () => expect(item.id, 'order-1'));
    test('title from first item', () => expect(item.title, 'Air Max'));
    test(
      'coverImage from first item',
      () => expect(item.coverImage, 'https://cdn.example.com/img.jpg'),
    );
    test('price from fees.total', () => expect(item.price, 100));
    test('status maps pending', () => expect(item.status, OrderStatus.pending));
    test(
      'counterpartName from seller (buyer view)',
      () => expect(item.counterpartName, 'Alice'),
    );
  });

  group('mapOrderListItem — price fallback', () {
    test('uses first item price when fees.total == 0', () {
      final raw = _baseListItem(fees: _baseFees(total: 0));
      expect(mapOrderListItem(raw).price, 100);
    });

    test('price is 0 when items list is empty and fees.total == 0', () {
      final raw = _baseListItem(
        items: const <Map<String, dynamic>>[],
        fees: _baseFees(total: 0),
      );
      expect(mapOrderListItem(raw).price, 0);
    });
  });

  group('mapOrderListItem — counterpart resolution', () {
    test('seller role → reads from buyer field', () {
      final raw = <String, dynamic>{
        ..._baseListItem(role: 'seller'),
        'buyer': <String, dynamic>{'id': 'buyer-1', 'displayName': 'Bob'},
      };
      expect(mapOrderListItem(raw).counterpartName, 'Bob');
    });
  });

  group('mapOrderListItem — coverImage null when item has no image', () {
    test('coverImage is null when image absent', () {
      final raw = _baseListItem(
        items: <Map<String, dynamic>>[_baseItem(image: null)],
      );
      expect(mapOrderListItem(raw).coverImage, isNull);
    });
  });

  group('mapOrderListItem — createdAtLabel', () {
    test('label is null when createdAt absent', () {
      expect(mapOrderListItem(_baseListItem()).createdAtLabel, isNull);
    });

    test('produces a time label for a recent createdAt', () {
      final recent = DateTime.now()
          .subtract(const Duration(hours: 2))
          .toIso8601String();
      final raw = _baseListItem(createdAt: recent);
      expect(
        mapOrderListItem(raw).createdAtLabel,
        matches(RegExp(r'^\d+h ago$')),
      );
    });

    test('day label for yesterday', () {
      final yesterday = DateTime.now()
          .subtract(const Duration(hours: 25))
          .toIso8601String();
      final raw = _baseListItem(createdAt: yesterday);
      expect(
        mapOrderListItem(raw).createdAtLabel,
        matches(RegExp(r'^\d+d ago$')),
      );
    });

    test('minutes label for recent', () {
      final recent = DateTime.now()
          .subtract(const Duration(minutes: 5))
          .toIso8601String();
      final raw = _baseListItem(createdAt: recent);
      expect(
        mapOrderListItem(raw).createdAtLabel,
        matches(RegExp(r'^\d+m ago$')),
      );
    });

    test('Just now for very recent', () {
      final now = DateTime.now()
          .subtract(const Duration(seconds: 30))
          .toIso8601String();
      final raw = _baseListItem(createdAt: now);
      expect(mapOrderListItem(raw).createdAtLabel, 'Just now');
    });
  });

  group('mapOrderListItem — OrderStatus.fromApi branches', () {
    for (final entry in <String, OrderStatus>{
      'paid': OrderStatus.pending,
      'waitingForExpedition': OrderStatus.waitingForExpedition,
      'shipped': OrderStatus.inDelivery,
      'deliveryCompleted': OrderStatus.deliveryCompleted,
      'delivered': OrderStatus.completed,
      'returnRequested': OrderStatus.returnRequested,
      'cancelled': OrderStatus.canceled,
      'unknown_xyz': OrderStatus.unknown,
    }.entries) {
      test('${entry.key} → ${entry.value}', () {
        final raw = _baseListItem(status: entry.key);
        expect(mapOrderListItem(raw).status, entry.value);
      });
    }
  });

  group('mapOrderListItem — _id fallback', () {
    test('reads _id when id is absent', () {
      final raw = <String, dynamic>{..._baseListItem(), '_id': 'alt-id'}
        ..remove('id');
      expect(mapOrderListItem(raw).id, 'alt-id');
    });
  });

  // ---------------------------------------------------------------------------
  // mapOrder
  // ---------------------------------------------------------------------------

  group('mapOrder — null/empty input', () {
    test('null input returns safe defaults', () {
      final order = mapOrder(null);
      expect(order.id, isEmpty);
      expect(order.status, OrderStatus.unknown);
      expect(order.viewerRole, OrderRole.buyer);
      expect(order.availableActions, isEmpty);
      expect(order.items, isEmpty);
    });
  });

  group('mapOrder — standard fields', () {
    late final dynamic order;
    setUpAll(() => order = mapOrder(_baseOrderDetail()));

    test('id', () => expect(order.id, 'order-99'));
    test('status pending', () => expect(order.status, OrderStatus.pending));
    test('viewerRole buyer', () => expect(order.viewerRole, OrderRole.buyer));
    test('counterpart id', () => expect(order.counterpart.id, 'seller-1'));
    test(
      'counterpart displayName',
      () => expect(order.counterpart.displayName, 'Alice'),
    );
    test('counterpart isPro', () => expect(order.counterpart.isPro, isTrue));
    test('items length', () => expect(order.items, hasLength(1)));
    test('first item title', () => expect(order.items.first.title, 'Air Max'));
    test('fees subtotal', () => expect(order.fees.subtotal, 80));
    test('fees total', () => expect(order.fees.total, 100));
    test('deliveryName null', () => expect(order.deliveryName, isNull));
    test('deliveryAddress null', () => expect(order.deliveryAddress, isNull));
    test('returnReason null', () => expect(order.returnReason, isNull));
  });

  group('mapOrder — seller role', () {
    test('seller role → reads from buyer field', () {
      final raw = <String, dynamic>{
        ..._baseOrderDetail(role: 'seller'),
        'buyer': <String, dynamic>{
          'id': 'b1',
          'displayName': 'Carol',
          'isPro': false,
        },
      };
      final order = mapOrder(raw);
      expect(order.viewerRole, OrderRole.seller);
      expect(order.counterpart.displayName, 'Carol');
    });
  });

  group('mapOrder — availableActions', () {
    test('ship action parsed', () {
      final order = mapOrder(_baseOrderDetail(actions: <String>['shipOrder']));
      expect(order.availableActions, contains(OrderAction.ship));
    });

    test('confirmReceipt parsed', () {
      final order = mapOrder(
        _baseOrderDetail(actions: <String>['confirmReceipt']),
      );
      expect(order.availableActions, contains(OrderAction.confirmReceipt));
    });

    test('cancel and review parsed together', () {
      final order = mapOrder(
        _baseOrderDetail(actions: <String>['cancel', 'review']),
      );
      expect(
        order.availableActions,
        containsAll(<OrderAction>[OrderAction.cancel, OrderAction.review]),
      );
    });

    test('null availableActions gives empty set', () {
      final raw = Map<String, dynamic>.from(_baseOrderDetail())
        ..remove('availableActions');
      expect(mapOrder(raw).availableActions, isEmpty);
    });
  });

  group('mapOrder — returnReason', () {
    test('returnReason is forwarded', () {
      final order = mapOrder(_baseOrderDetail(returnReason: 'Item damaged'));
      expect(order.returnReason, 'Item damaged');
    });
  });

  group('mapOrder — deliveryAddress', () {
    test('deliveryName and address line composed correctly', () {
      final order = mapOrder(
        _baseOrderDetail(
          deliveryAddress: <String, dynamic>{
            'name': 'John Doe',
            'line1': '12 Rue de Rivoli',
            'city': 'Paris',
          },
        ),
      );
      expect(order.deliveryName, 'John Doe');
      expect(order.deliveryAddress, contains('Paris'));
      expect(order.deliveryAddress, contains('12 Rue de Rivoli'));
    });
  });

  group('mapOrder — tracking', () {
    test('no tracking key → default carrier EMX', () {
      final order = mapOrder(_baseOrderDetail());
      expect(order.tracking.carrier, 'EMX');
      expect(order.tracking.steps, isEmpty);
    });

    test('tracking fields mapped', () {
      final raw = _baseOrderDetail(
        tracking: <String, dynamic>{
          'carrier': 'DHL',
          'trackingNumber': 'TRK123',
          'liveTrackingUrl': 'https://track.dhl.com/TRK123',
          'steps': <dynamic>[
            <String, dynamic>{'label': 'Picked up', 'done': true},
            <String, dynamic>{'label': 'In transit', 'active': true},
            <String, dynamic>{'label': 'Delivered'},
          ],
        },
      );
      final order = mapOrder(raw);
      expect(order.tracking.carrier, 'DHL');
      expect(order.tracking.trackingNumber, 'TRK123');
      expect(order.tracking.liveTrackingUrl, 'https://track.dhl.com/TRK123');
      expect(order.tracking.steps, hasLength(3));
      expect(order.tracking.steps[0].state, TrackStepState.done);
      expect(order.tracking.steps[1].state, TrackStepState.active);
      expect(order.tracking.steps[2].state, TrackStepState.pending);
    });

    test('step with state == done string', () {
      final raw = _baseOrderDetail(
        tracking: <String, dynamic>{
          'steps': <dynamic>[
            <String, dynamic>{'label': 'Shipped', 'state': 'done'},
          ],
        },
      );
      final step = mapOrder(raw).tracking.steps.first;
      expect(step.state, TrackStepState.done);
    });

    test('step with status == completed string', () {
      final raw = _baseOrderDetail(
        tracking: <String, dynamic>{
          'steps': <dynamic>[
            <String, dynamic>{'label': 'Done', 'status': 'completed'},
          ],
        },
      );
      expect(mapOrder(raw).tracking.steps.first.state, TrackStepState.done);
    });

    test('step sublabel mapped from timestamp key', () {
      final raw = _baseOrderDetail(
        tracking: <String, dynamic>{
          'steps': <dynamic>[
            <String, dynamic>{'label': 'A', 'timestamp': '2024-01-01'},
          ],
        },
      );
      expect(mapOrder(raw).tracking.steps.first.sublabel, '2024-01-01');
    });
  });

  group('mapOrder — items branch', () {
    test('empty items list', () {
      final raw = Map<String, dynamic>.from(_baseOrderDetail())
        ..['items'] = <dynamic>[];
      expect(mapOrder(raw).items, isEmpty);
    });

    test('item reads productId from id key as fallback', () {
      final raw = <String, dynamic>{
        ..._baseOrderDetail(),
        'items': <dynamic>[
          <String, dynamic>{
            'id': 'prod-fallback',
            'name': 'Jacket',
            'price': 50,
          },
        ],
      };
      final item = mapOrder(raw).items.first;
      expect(item.productId, 'prod-fallback');
      expect(item.title, 'Jacket');
      expect(item.price, 50);
    });

    test('item coverImage from coverImage key', () {
      final raw = <String, dynamic>{
        ..._baseOrderDetail(),
        'items': <dynamic>[
          <String, dynamic>{
            'productId': 'x',
            'title': 'T',
            'price': 10,
            'coverImage': 'https://cdn.example.com/cover.jpg',
          },
        ],
      };
      expect(
        mapOrder(raw).items.first.image,
        'https://cdn.example.com/cover.jpg',
      );
    });
  });

  group('mapOrder — fees numeric-string parsing', () {
    test('fees as numeric strings are parsed', () {
      final raw = <String, dynamic>{
        ..._baseOrderDetail(),
        'fees': <String, dynamic>{
          'subtotal': '70',
          'shipping': '8',
          'protection': '2',
          'vat': '1',
          'total': '81',
        },
      };
      final fees = mapOrder(raw).fees;
      expect(fees.subtotal, 70);
      expect(fees.total, 81);
    });
  });
}
