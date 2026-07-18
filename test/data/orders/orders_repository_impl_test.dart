// test/data/orders/orders_repository_impl_test.dart

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/data/orders/orders_repository_impl.dart';
import 'package:klozy/src/domain/orders/entity/order.dart';
import 'package:klozy/src/domain/orders/entity/order_action.dart';
import 'package:klozy/src/domain/orders/entity/order_list_item.dart';
import 'package:klozy/src/domain/orders/entity/order_status.dart';
import 'package:mocktail/mocktail.dart';

// ── Mocks ──────────────────────────────────────────────────────────────────

class _MockDio extends Mock implements Dio {}

// ── Helpers ────────────────────────────────────────────────────────────────

Response<T> _ok<T>(String path, T data) => Response<T>(
  requestOptions: RequestOptions(path: path),
  statusCode: 200,
  data: data,
);

Response<dynamic> _voidOk(String path) => Response<dynamic>(
  requestOptions: RequestOptions(path: path),
  statusCode: 200,
);

/// Minimal order-list row to avoid mapping errors.
Map<String, dynamic> _listRow({
  String id = 'ord1',
  String status = 'pending',
  String role = 'buyer',
}) => <String, dynamic>{
  'id': id,
  'status': status,
  'viewerRole': role,
  'items': <dynamic>[
    <String, dynamic>{
      'productId': 'p1',
      'title': 'Test Item',
      'brand': 'Nike',
      'size': 'M',
      'price': 100,
    },
  ],
  'seller': <String, dynamic>{'displayName': 'Seller'},
};

/// Minimal order detail JSON.
Map<String, dynamic> _detailJson({String id = 'ord1'}) => <String, dynamic>{
  'id': id,
  'status': 'pending',
  'viewerRole': 'buyer',
  'items': <dynamic>[
    <String, dynamic>{
      'productId': 'p1',
      'title': 'Test Item',
      'brand': 'Nike',
      'size': 'M',
      'price': 100,
    },
  ],
  'seller': <String, dynamic>{'displayName': 'Seller'},
  'tracking': <String, dynamic>{'carrier': 'EMX'},
};

void main() {
  late _MockDio mockDio;
  late OrdersRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(Options());
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    mockDio = _MockDio();
    repo = OrdersRepositoryImpl(mockDio);
  });

  // ── getOrders ───────────────────────────────────────────────────────────

  group('getOrders', () {
    test('passes buying role for buyer', () async {
      when(
        () => mockDio.get<dynamic>(
          'v1/orders',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => _ok<dynamic>('v1/orders', <dynamic>[_listRow()]),
      );

      final List<OrderListItem> result = await repo.getOrders(
        role: OrderRole.buyer,
      );

      expect(result, hasLength(1));
      expect(result.first.id, 'ord1');

      final VerificationResult v = verify(
        () => mockDio.get<dynamic>(
          'v1/orders',
          queryParameters: captureAny(named: 'queryParameters'),
        ),
      );
      final Map<String, dynamic> params =
          v.captured.first as Map<String, dynamic>;
      expect(params['role'], 'buying');
    });

    test('passes selling role for seller', () async {
      when(
        () => mockDio.get<dynamic>(
          'v1/orders',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => _ok<dynamic>('v1/orders', <dynamic>[]));

      await repo.getOrders(role: OrderRole.seller);

      final VerificationResult v = verify(
        () => mockDio.get<dynamic>(
          'v1/orders',
          queryParameters: captureAny(named: 'queryParameters'),
        ),
      );
      final Map<String, dynamic> params =
          v.captured.first as Map<String, dynamic>;
      expect(params['role'], 'selling');
    });

    test('passes completed state filter', () async {
      when(
        () => mockDio.get<dynamic>(
          'v1/orders',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => _ok<dynamic>('v1/orders', <dynamic>[]));

      await repo.getOrders(
        role: OrderRole.buyer,
        state: OrderListState.completed,
      );

      final VerificationResult v = verify(
        () => mockDio.get<dynamic>(
          'v1/orders',
          queryParameters: captureAny(named: 'queryParameters'),
        ),
      );
      final Map<String, dynamic> params =
          v.captured.first as Map<String, dynamic>;
      expect(params['state'], 'completed');
    });

    test('passes in_progress state filter', () async {
      when(
        () => mockDio.get<dynamic>(
          'v1/orders',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => _ok<dynamic>('v1/orders', <dynamic>[]));

      await repo.getOrders(
        role: OrderRole.buyer,
        state: OrderListState.inProgress,
      );

      final VerificationResult v = verify(
        () => mockDio.get<dynamic>(
          'v1/orders',
          queryParameters: captureAny(named: 'queryParameters'),
        ),
      );
      final Map<String, dynamic> params =
          v.captured.first as Map<String, dynamic>;
      expect(params['state'], 'in_progress');
    });

    test('maps from orders envelope key', () async {
      when(
        () => mockDio.get<dynamic>(
          'v1/orders',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => _ok<dynamic>('v1/orders', <String, dynamic>{
          'orders': <dynamic>[_listRow(id: 'ord2')],
        }),
      );

      final List<OrderListItem> result = await repo.getOrders(
        role: OrderRole.buyer,
      );

      expect(result, hasLength(1));
      expect(result.first.id, 'ord2');
    });

    test('maps from data envelope key', () async {
      when(
        () => mockDio.get<dynamic>(
          'v1/orders',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => _ok<dynamic>('v1/orders', <String, dynamic>{
          'data': <dynamic>[_listRow(id: 'ord3')],
        }),
      );

      final List<OrderListItem> result = await repo.getOrders(
        role: OrderRole.buyer,
      );

      expect(result.first.id, 'ord3');
    });
  });

  // ── getOrder ────────────────────────────────────────────────────────────

  group('getOrder', () {
    test('maps order detail from GET /v1/orders/:id', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>('v1/orders/ord1'),
      ).thenAnswer(
        (_) async => _ok<Map<String, dynamic>>('v1/orders/ord1', _detailJson()),
      );

      final Order result = await repo.getOrder('ord1');

      expect(result.id, 'ord1');
      expect(result.status, OrderStatus.pending);
      expect(result.viewerRole, OrderRole.buyer);
      expect(result.items, hasLength(1));
    });
  });

  // ── ship ────────────────────────────────────────────────────────────────

  group('ship', () {
    test('posts to v1/orders/:id/ship', () async {
      when(
        () => mockDio.post<dynamic>('v1/orders/ord1/ship'),
      ).thenAnswer((_) async => _voidOk('v1/orders/ord1/ship'));

      await repo.ship('ord1');

      verify(() => mockDio.post<dynamic>('v1/orders/ord1/ship')).called(1);
    });
  });

  // ── confirmReceipt ──────────────────────────────────────────────────────

  group('confirmReceipt', () {
    test('posts to v1/orders/:id/confirm-receipt', () async {
      when(
        () => mockDio.post<dynamic>('v1/orders/ord1/confirm-receipt'),
      ).thenAnswer((_) async => _voidOk('v1/orders/ord1/confirm-receipt'));

      await repo.confirmReceipt('ord1');

      verify(
        () => mockDio.post<dynamic>('v1/orders/ord1/confirm-receipt'),
      ).called(1);
    });
  });

  // ── reportProblem ───────────────────────────────────────────────────────

  group('reportProblem', () {
    test('posts reason to v1/orders/:id/report-problem', () async {
      when(
        () => mockDio.post<dynamic>(
          'v1/orders/ord1/report-problem',
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => _voidOk('v1/orders/ord1/report-problem'));

      await repo.reportProblem('ord1', 'item not as described');

      final VerificationResult v = verify(
        () => mockDio.post<dynamic>(
          'v1/orders/ord1/report-problem',
          data: captureAny(named: 'data'),
        ),
      );
      final Map<String, dynamic> body =
          v.captured.first as Map<String, dynamic>;
      expect(body['reason'], 'item not as described');
    });
  });

  // ── cancel ──────────────────────────────────────────────────────────────

  group('cancel', () {
    test('posts to v1/orders/:id/cancel', () async {
      when(
        () => mockDio.post<dynamic>('v1/orders/ord1/cancel'),
      ).thenAnswer((_) async => _voidOk('v1/orders/ord1/cancel'));

      await repo.cancel('ord1');

      verify(() => mockDio.post<dynamic>('v1/orders/ord1/cancel')).called(1);
    });
  });

  // ── review ──────────────────────────────────────────────────────────────

  group('review', () {
    test('posts rating and body to v1/orders/:id/review', () async {
      when(
        () => mockDio.post<dynamic>(
          'v1/orders/ord1/review',
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => _voidOk('v1/orders/ord1/review'));

      await repo.review('ord1', rating: 5, body: 'Great seller!');

      final VerificationResult v = verify(
        () => mockDio.post<dynamic>(
          'v1/orders/ord1/review',
          data: captureAny(named: 'data'),
        ),
      );
      final Map<String, dynamic> body =
          v.captured.first as Map<String, dynamic>;
      expect(body['rating'], 5);
      expect(body['body'], 'Great seller!');
    });

    test('omits body when null or empty', () async {
      when(
        () => mockDio.post<dynamic>(
          'v1/orders/ord1/review',
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => _voidOk('v1/orders/ord1/review'));

      await repo.review('ord1', rating: 4);

      final VerificationResult v = verify(
        () => mockDio.post<dynamic>(
          'v1/orders/ord1/review',
          data: captureAny(named: 'data'),
        ),
      );
      final Map<String, dynamic> reqBody =
          v.captured.first as Map<String, dynamic>;
      expect(reqBody.containsKey('body'), isFalse);
    });
  });

  // ── acceptReturn ────────────────────────────────────────────────────────

  group('acceptReturn', () {
    test('posts to v1/orders/:id/accept-return with no body', () async {
      when(
        () => mockDio.post<dynamic>('v1/orders/ord1/accept-return'),
      ).thenAnswer((_) async => _voidOk('v1/orders/ord1/accept-return'));

      await repo.acceptReturn('ord1');

      verify(
        () => mockDio.post<dynamic>('v1/orders/ord1/accept-return'),
      ).called(1);
    });

    test('propagates DioException', () async {
      final DioException error = DioException(
        requestOptions: RequestOptions(path: 'v1/orders/ord1/accept-return'),
      );
      when(
        () => mockDio.post<dynamic>('v1/orders/ord1/accept-return'),
      ).thenThrow(error);

      expect(() => repo.acceptReturn('ord1'), throwsA(same(error)));
    });
  });

  // ── refuseReturn ────────────────────────────────────────────────────────

  group('refuseReturn', () {
    test('posts reason to v1/orders/:id/refuse-return', () async {
      when(
        () => mockDio.post<dynamic>(
          'v1/orders/ord1/refuse-return',
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => _voidOk('v1/orders/ord1/refuse-return'));

      await repo.refuseReturn('ord1', reason: 'item not received');

      final VerificationResult v = verify(
        () => mockDio.post<dynamic>(
          'v1/orders/ord1/refuse-return',
          data: captureAny(named: 'data'),
        ),
      );
      final Map<String, dynamic> body =
          v.captured.first as Map<String, dynamic>;
      expect(body['reason'], 'item not received');
    });

    test('propagates DioException', () async {
      final DioException error = DioException(
        requestOptions: RequestOptions(path: 'v1/orders/ord1/refuse-return'),
      );
      when(
        () => mockDio.post<dynamic>(
          'v1/orders/ord1/refuse-return',
          data: any(named: 'data'),
        ),
      ).thenThrow(error);

      expect(
        () => repo.refuseReturn('ord1', reason: 'item not received'),
        throwsA(same(error)),
      );
    });
  });
}
