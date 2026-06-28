// test/data/notifications/notifications_repository_impl_test.dart

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/data/notifications/notifications_repository_impl.dart';
import 'package:klozy/src/domain/notifications/entity/app_notification.dart';
import 'package:klozy/src/domain/notifications/entity/notification_type.dart';
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

void main() {
  late _MockDio mockDio;
  late NotificationsRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(Options());
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    mockDio = _MockDio();
    repo = NotificationsRepositoryImpl(mockDio);
  });

  // ── getNotifications ────────────────────────────────────────────────────

  group('getNotifications', () {
    test('maps bare list of notification objects', () async {
      when(
        () => mockDio.get<dynamic>(
          'v1/me/notifications',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => _ok<dynamic>('v1/me/notifications', <dynamic>[
          <String, dynamic>{
            'id': 'n1',
            'type': 'new_order',
            'title': 'New Order!',
            'body': 'You have a new order.',
            'read': false,
            'createdAt': '2024-05-01T08:00:00Z',
            'data': <String, dynamic>{'orderId': 'ord-001'},
          },
        ]),
      );

      final List<AppNotification> result = await repo.getNotifications(
        page: 1,
        limit: 30,
      );

      expect(result, hasLength(1));
      expect(result.first.id, 'n1');
      expect(result.first.type, NotificationType.newOrder);
      expect(result.first.title, 'New Order!');
      expect(result.first.read, isFalse);
      expect(result.first.orderId, 'ord-001');
      expect(result.first.createdAt, isNotNull);
    });

    test('maps from data envelope', () async {
      when(
        () => mockDio.get<dynamic>(
          'v1/me/notifications',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => _ok<dynamic>('v1/me/notifications', <String, dynamic>{
          'data': <dynamic>[
            <String, dynamic>{
              '_id': 'n2',
              'type': 'new_follower',
              'title': 'New Follower',
              'body': 'Someone followed you.',
              'isRead': true,
            },
          ],
        }),
      );

      final List<AppNotification> result = await repo.getNotifications();
      expect(result.first.id, 'n2');
      expect(result.first.type, NotificationType.newFollower);
      expect(result.first.read, isTrue);
    });

    test('maps from notifications envelope key', () async {
      when(
        () => mockDio.get<dynamic>(
          'v1/me/notifications',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => _ok<dynamic>('v1/me/notifications', <String, dynamic>{
          'notifications': <dynamic>[
            <String, dynamic>{
              'id': 'n3',
              'type': 'offer_accepted',
              'title': 'Offer Accepted',
              'body': 'Your offer was accepted.',
            },
          ],
        }),
      );

      final List<AppNotification> result = await repo.getNotifications();
      expect(result.first.type, NotificationType.offerAccepted);
    });

    test('passes unreadOnly filter as query param', () async {
      when(
        () => mockDio.get<dynamic>(
          'v1/me/notifications',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => _ok<dynamic>('v1/me/notifications', <dynamic>[]),
      );

      await repo.getNotifications(unreadOnly: true);

      final VerificationResult v = verify(
        () => mockDio.get<dynamic>(
          'v1/me/notifications',
          queryParameters: captureAny(named: 'queryParameters'),
        ),
      );
      final Map<String, dynamic> params =
          v.captured.first as Map<String, dynamic>;
      expect(params['unread'], isTrue);
    });

    test('does not send unread param when unreadOnly is false', () async {
      when(
        () => mockDio.get<dynamic>(
          'v1/me/notifications',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => _ok<dynamic>('v1/me/notifications', <dynamic>[]),
      );

      await repo.getNotifications(unreadOnly: false);

      final VerificationResult v = verify(
        () => mockDio.get<dynamic>(
          'v1/me/notifications',
          queryParameters: captureAny(named: 'queryParameters'),
        ),
      );
      final Map<String, dynamic> params =
          v.captured.first as Map<String, dynamic>;
      expect(params.containsKey('unread'), isFalse);
    });
  });

  // ── unreadCount ─────────────────────────────────────────────────────────

  group('unreadCount', () {
    test('returns num directly when response data is a number', () async {
      when(
        () => mockDio.get<dynamic>('v1/me/notifications/unread-count'),
      ).thenAnswer(
        (_) async => _ok<dynamic>('v1/me/notifications/unread-count', 5),
      );

      final int result = await repo.unreadCount();
      expect(result, 5);
    });

    test('reads count key from map response', () async {
      when(
        () => mockDio.get<dynamic>('v1/me/notifications/unread-count'),
      ).thenAnswer(
        (_) async => _ok<dynamic>(
          'v1/me/notifications/unread-count',
          <String, dynamic>{'count': 12},
        ),
      );

      final int result = await repo.unreadCount();
      expect(result, 12);
    });

    test('reads unread key from map response', () async {
      when(
        () => mockDio.get<dynamic>('v1/me/notifications/unread-count'),
      ).thenAnswer(
        (_) async => _ok<dynamic>(
          'v1/me/notifications/unread-count',
          <String, dynamic>{'unread': 3},
        ),
      );

      final int result = await repo.unreadCount();
      expect(result, 3);
    });

    test('reads unreadCount key from map response', () async {
      when(
        () => mockDio.get<dynamic>('v1/me/notifications/unread-count'),
      ).thenAnswer(
        (_) async => _ok<dynamic>(
          'v1/me/notifications/unread-count',
          <String, dynamic>{'unreadCount': 7},
        ),
      );

      final int result = await repo.unreadCount();
      expect(result, 7);
    });

    test('returns 0 when data is null', () async {
      when(
        () => mockDio.get<dynamic>('v1/me/notifications/unread-count'),
      ).thenAnswer(
        (_) async => _ok<dynamic>('v1/me/notifications/unread-count', null),
      );

      final int result = await repo.unreadCount();
      expect(result, 0);
    });
  });

  // ── markRead ────────────────────────────────────────────────────────────

  group('markRead', () {
    test('patches the correct endpoint', () async {
      when(
        () => mockDio.patch<dynamic>('v1/me/notifications/n1/read'),
      ).thenAnswer((_) async => _voidOk('v1/me/notifications/n1/read'));

      await repo.markRead('n1');

      verify(
        () => mockDio.patch<dynamic>('v1/me/notifications/n1/read'),
      ).called(1);
    });
  });

  // ── markAllRead ─────────────────────────────────────────────────────────

  group('markAllRead', () {
    test('posts to the read-all endpoint', () async {
      when(
        () => mockDio.post<dynamic>('v1/me/notifications/read-all'),
      ).thenAnswer((_) async => _voidOk('v1/me/notifications/read-all'));

      await repo.markAllRead();

      verify(
        () => mockDio.post<dynamic>('v1/me/notifications/read-all'),
      ).called(1);
    });
  });

  // ── remove ──────────────────────────────────────────────────────────────

  group('remove', () {
    test('deletes the notification', () async {
      when(
        () => mockDio.delete<dynamic>('v1/me/notifications/n1'),
      ).thenAnswer((_) async => _voidOk('v1/me/notifications/n1'));

      await repo.remove('n1');

      verify(() => mockDio.delete<dynamic>('v1/me/notifications/n1')).called(1);
    });
  });

  // ── registerDeviceToken ─────────────────────────────────────────────────

  group('registerDeviceToken', () {
    test('posts token and platform to v1/me/device-tokens', () async {
      when(
        () => mockDio.post<dynamic>(
          'v1/me/device-tokens',
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => _voidOk('v1/me/device-tokens'));

      await repo.registerDeviceToken(token: 'tok123', platform: 'ios');

      final VerificationResult v = verify(
        () => mockDio.post<dynamic>(
          'v1/me/device-tokens',
          data: captureAny(named: 'data'),
        ),
      );
      final Map<String, dynamic> body =
          v.captured.first as Map<String, dynamic>;
      expect(body['token'], 'tok123');
      expect(body['platform'], 'ios');
    });
  });

  // ── removeDeviceToken ───────────────────────────────────────────────────

  group('removeDeviceToken', () {
    test('deletes the URL-encoded token', () async {
      const String token = 'tok:abc/123';
      final String encoded = Uri.encodeComponent(token);

      when(
        () => mockDio.delete<dynamic>('v1/me/device-tokens/$encoded'),
      ).thenAnswer((_) async => _voidOk('v1/me/device-tokens/$encoded'));

      await repo.removeDeviceToken(token);

      verify(
        () => mockDio.delete<dynamic>('v1/me/device-tokens/$encoded'),
      ).called(1);
    });
  });
}
