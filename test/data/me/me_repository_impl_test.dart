// test/data/me/me_repository_impl_test.dart
//
// Covers MeRepositoryImpl methods NOT already exercised by
// me_repository_impl_cache_test.dart (getMe / invalidate / updateProfile /
// setAddress / setSellerRole / setPayoutIban / updatePreferences).

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/core/network/cache/session_cache.dart';
import 'package:klozy/src/data/me/me_repository_impl.dart';
import 'package:klozy/src/domain/me/entity/address.dart';
import 'package:klozy/src/domain/me/entity/address_input.dart';
import 'package:klozy/src/domain/me/entity/blocked_user.dart';
import 'package:klozy/src/domain/me/entity/connect_status.dart';
import 'package:klozy/src/domain/me/entity/me_profile.dart';
import 'package:klozy/src/domain/me/entity/notification_settings.dart';
import 'package:klozy/src/domain/me/entity/payout.dart';
import 'package:klozy/src/domain/me/entity/preferences_input.dart';
import 'package:klozy/src/domain/me/entity/seller_stats.dart';
import 'package:mocktail/mocktail.dart';

// ── Mocks ──────────────────────────────────────────────────────────────────

class _MockDio extends Mock implements Dio {}

class _MockSessionCache extends Mock implements SessionCache {}

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
  late _MockSessionCache mockCache;
  late MeRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(Options());
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    mockDio = _MockDio();
    mockCache = _MockSessionCache();
    repo = MeRepositoryImpl(mockDio, mockCache);

    // Default void stubs.
    when(() => mockCache.invalidateGroup(any())).thenAnswer((_) {});
  });

  // ── getAddresses ────────────────────────────────────────────────────────

  group('getAddresses', () {
    test('maps a bare list response', () async {
      when(() => mockDio.get<dynamic>('v1/me/addresses')).thenAnswer(
        (_) async => _ok<dynamic>('v1/me/addresses', <dynamic>[
          <String, dynamic>{
            'id': 'a1',
            'line1': '1 Main St',
            'city': 'Dubai',
            'emirate': 'Dubai',
            'country': 'UAE',
            'isDefault': true,
          },
        ]),
      );

      final List<Address> result = await repo.getAddresses();

      expect(result, hasLength(1));
      expect(result.first.id, 'a1');
      expect(result.first.city, 'Dubai');
      expect(result.first.isDefault, isTrue);
    });

    test('maps an envelope response with data list', () async {
      when(() => mockDio.get<dynamic>('v1/me/addresses')).thenAnswer(
        (_) async => _ok<dynamic>('v1/me/addresses', <String, dynamic>{
          'data': <dynamic>[
            <String, dynamic>{
              '_id': 'a2',
              'line1': '2 Side Rd',
              'city': 'Abu Dhabi',
              'emirate': 'Abu Dhabi',
            },
          ],
        }),
      );

      final List<Address> result = await repo.getAddresses();

      expect(result, hasLength(1));
      expect(result.first.id, 'a2');
    });

    test('returns empty list when data is null', () async {
      when(
        () => mockDio.get<dynamic>('v1/me/addresses'),
      ).thenAnswer((_) async => _ok<dynamic>('v1/me/addresses', null));

      final List<Address> result = await repo.getAddresses();
      expect(result, isEmpty);
    });
  });

  // ── createAddress ───────────────────────────────────────────────────────

  group('createAddress', () {
    test('posts to v1/me/addresses and maps the response', () async {
      when(
        () => mockDio.post<Map<String, dynamic>>(
          'v1/me/addresses',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async =>
            _ok<Map<String, dynamic>>('v1/me/addresses', <String, dynamic>{
              'id': 'a3',
              'line1': '3 New St',
              'city': 'Sharjah',
              'emirate': 'Sharjah',
            }),
      );

      const AddressInput input = AddressInput(
        line1: '3 New St',
        city: 'Sharjah',
        emirate: 'Sharjah',
      );
      final Address result = await repo.createAddress(input);

      expect(result.id, 'a3');
      expect(result.city, 'Sharjah');
      verify(
        () => mockDio.post<Map<String, dynamic>>(
          'v1/me/addresses',
          data: any(named: 'data'),
        ),
      ).called(1);
    });
  });

  // ── updateAddress ───────────────────────────────────────────────────────

  group('updateAddress', () {
    test('patches v1/me/addresses/:id and maps the response', () async {
      when(
        () => mockDio.patch<Map<String, dynamic>>(
          'v1/me/addresses/a3',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async =>
            _ok<Map<String, dynamic>>('v1/me/addresses/a3', <String, dynamic>{
              'id': 'a3',
              'line1': 'Updated St',
              'city': 'Dubai',
              'emirate': 'Dubai',
            }),
      );

      const AddressInput input = AddressInput(
        line1: 'Updated St',
        city: 'Dubai',
        emirate: 'Dubai',
      );
      final Address result = await repo.updateAddress('a3', input);

      expect(result.id, 'a3');
      expect(result.line1, 'Updated St');
    });
  });

  // ── deleteAddress ───────────────────────────────────────────────────────

  group('deleteAddress', () {
    test('calls DELETE v1/me/addresses/:id', () async {
      when(
        () => mockDio.delete<dynamic>('v1/me/addresses/a3'),
      ).thenAnswer((_) async => _voidOk('v1/me/addresses/a3'));

      await repo.deleteAddress('a3');

      verify(() => mockDio.delete<dynamic>('v1/me/addresses/a3')).called(1);
    });
  });

  // ── setDefaultAddress ───────────────────────────────────────────────────

  group('setDefaultAddress', () {
    test('calls PUT and returns mapped list', () async {
      when(() => mockDio.put<dynamic>('v1/me/addresses/a1/default')).thenAnswer(
        (_) async => _ok<dynamic>('v1/me/addresses/a1/default', <dynamic>[
          <String, dynamic>{
            'id': 'a1',
            'line1': '1 Main',
            'city': 'Dubai',
            'emirate': 'Dubai',
            'isDefault': true,
          },
        ]),
      );

      final List<Address> result = await repo.setDefaultAddress('a1');
      expect(result, hasLength(1));
      expect(result.first.isDefault, isTrue);
    });
  });

  // ── getPayouts ──────────────────────────────────────────────────────────

  group('getPayouts', () {
    test('maps pending/unknown payout items', () async {
      when(() => mockDio.get<Map<String, dynamic>>('v1/me/payouts')).thenAnswer(
        (_) async =>
            _ok<Map<String, dynamic>>('v1/me/payouts', <String, dynamic>{
              'pendingFils': 500,
              'lifetimePaidFils': 1000,
              'items': <dynamic>[
                <String, dynamic>{
                  'orderId': 'ord1',
                  'grossFils': 200,
                  'status': 'PENDING',
                  'method': 'UNKNOWN_METHOD',
                },
              ],
            }),
      );

      final PayoutSummary result = await repo.getPayouts();

      expect(result.pendingFils, 500);
      expect(result.lifetimePaidFils, 1000);
      expect(result.items, hasLength(1));
      expect(result.items.first.status, PayoutStatus.pending);
      expect(result.items.first.method, PayoutMethod.unknown);
    });

    test('maps COMPLETED/IBAN payout item', () async {
      when(() => mockDio.get<Map<String, dynamic>>('v1/me/payouts')).thenAnswer(
        (_) async =>
            _ok<Map<String, dynamic>>('v1/me/payouts', <String, dynamic>{
              'items': <dynamic>[
                <String, dynamic>{
                  'orderId': 'ord2',
                  'status': 'COMPLETED',
                  'method': 'IBAN',
                  'netFils': 180,
                  'createdAt': '2024-01-15T10:00:00Z',
                },
              ],
            }),
      );

      final PayoutSummary result = await repo.getPayouts();

      expect(result.items.first.status, PayoutStatus.completed);
      expect(result.items.first.method, PayoutMethod.iban);
      expect(result.items.first.netFils, 180);
      expect(result.items.first.createdAt, isNotNull);
    });

    test('maps REVERSAL/STRIPE_CONNECT payout item', () async {
      when(() => mockDio.get<Map<String, dynamic>>('v1/me/payouts')).thenAnswer(
        (_) async =>
            _ok<Map<String, dynamic>>('v1/me/payouts', <String, dynamic>{
              'items': <dynamic>[
                <String, dynamic>{
                  'orderId': 'ord3',
                  'status': 'REVERSAL',
                  'method': 'STRIPE_CONNECT',
                },
              ],
            }),
      );

      final PayoutSummary result = await repo.getPayouts();

      expect(result.items.first.status, PayoutStatus.reversal);
      expect(result.items.first.method, PayoutMethod.stripeConnect);
    });

    test('returns empty items when list is absent', () async {
      when(() => mockDio.get<Map<String, dynamic>>('v1/me/payouts')).thenAnswer(
        (_) async =>
            _ok<Map<String, dynamic>>('v1/me/payouts', <String, dynamic>{}),
      );

      final PayoutSummary result = await repo.getPayouts();
      expect(result.items, isEmpty);
      expect(result.pendingFils, 0);
    });
  });

  // ── getConnectStatus ────────────────────────────────────────────────────

  group('getConnectStatus', () {
    test('maps COMPLETE onboarding', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>('v1/me/seller-connect'),
      ).thenAnswer(
        (_) async =>
            _ok<Map<String, dynamic>>('v1/me/seller-connect', <String, dynamic>{
              'accountId': 'acct_123',
              'onboardingStatus': 'COMPLETE',
              'detailsSubmitted': true,
              'chargesEnabled': true,
              'payoutsEnabled': true,
            }),
      );

      final ConnectStatus result = await repo.getConnectStatus();

      expect(result.accountId, 'acct_123');
      expect(result.onboarding, ConnectOnboarding.complete);
      expect(result.detailsSubmitted, isTrue);
      expect(result.chargesEnabled, isTrue);
      expect(result.payoutsEnabled, isTrue);
    });

    test('maps PENDING onboarding', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>('v1/me/seller-connect'),
      ).thenAnswer(
        (_) async => _ok<Map<String, dynamic>>(
          'v1/me/seller-connect',
          <String, dynamic>{'onboardingStatus': 'PENDING'},
        ),
      );

      final ConnectStatus result = await repo.getConnectStatus();
      expect(result.onboarding, ConnectOnboarding.pending);
    });

    test('falls back to notStarted for unknown onboardingStatus', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>('v1/me/seller-connect'),
      ).thenAnswer(
        (_) async => _ok<Map<String, dynamic>>(
          'v1/me/seller-connect',
          <String, dynamic>{},
        ),
      );

      final ConnectStatus result = await repo.getConnectStatus();
      expect(result.onboarding, ConnectOnboarding.notStarted);
    });
  });

  // ── createKybLink ───────────────────────────────────────────────────────

  group('createKybLink', () {
    test('posts and returns url string', () async {
      when(
        () =>
            mockDio.post<Map<String, dynamic>>('v1/me/seller-connect/kyb-link'),
      ).thenAnswer(
        (_) async => _ok<Map<String, dynamic>>(
          'v1/me/seller-connect/kyb-link',
          <String, dynamic>{'url': 'https://connect.stripe.com/onboard/abc'},
        ),
      );

      final String? url = await repo.createKybLink();
      expect(url, 'https://connect.stripe.com/onboard/abc');
    });

    test('returns null when url key missing', () async {
      when(
        () =>
            mockDio.post<Map<String, dynamic>>('v1/me/seller-connect/kyb-link'),
      ).thenAnswer(
        (_) async => _ok<Map<String, dynamic>>(
          'v1/me/seller-connect/kyb-link',
          <String, dynamic>{},
        ),
      );

      final String? url = await repo.createKybLink();
      expect(url, isNull);
    });
  });

  // ── getPreferences ──────────────────────────────────────────────────────

  group('getPreferences', () {
    test('maps full preferences response', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>('v1/me/preferences'),
      ).thenAnswer(
        (_) async =>
            _ok<Map<String, dynamic>>('v1/me/preferences', <String, dynamic>{
              'sizeSystem': 'US',
              'sizes': <String>['S', 'M'],
              'categoryIds': <String>['cat1'],
              'brandIds': <String>['brand1', 'brand2'],
            }),
      );

      final PreferencesInput result = await repo.getPreferences();

      expect(result.sizeSystem, 'US');
      expect(result.sizes, containsAll(<String>['S', 'M']));
      expect(result.categoryIds, contains('cat1'));
      expect(result.brandIds, hasLength(2));
    });

    test('defaults sizeSystem to EU when absent', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>('v1/me/preferences'),
      ).thenAnswer(
        (_) async =>
            _ok<Map<String, dynamic>>('v1/me/preferences', <String, dynamic>{}),
      );

      final PreferencesInput result = await repo.getPreferences();
      expect(result.sizeSystem, 'EU');
      expect(result.sizes, isEmpty);
    });
  });

  // ── getNotificationSettings ─────────────────────────────────────────────

  group('getNotificationSettings', () {
    test('maps push and email true when present', () async {
      when(() => mockDio.get<Map<String, dynamic>>('v1/me')).thenAnswer(
        (_) async => _ok<Map<String, dynamic>>('v1/me', <String, dynamic>{
          'id': 'u1',
          'notificationSettings': <String, dynamic>{
            'push': true,
            'email': true,
          },
        }),
      );

      final NotificationSettings result = await repo.getNotificationSettings();
      expect(result.push, isTrue);
      expect(result.email, isTrue);
    });

    test('maps push false explicitly', () async {
      when(() => mockDio.get<Map<String, dynamic>>('v1/me')).thenAnswer(
        (_) async => _ok<Map<String, dynamic>>('v1/me', <String, dynamic>{
          'id': 'u1',
          'notificationSettings': <String, dynamic>{
            'push': false,
            'email': false,
          },
        }),
      );

      final NotificationSettings result = await repo.getNotificationSettings();
      expect(result.push, isFalse);
      expect(result.email, isFalse);
    });

    test('defaults to true when notificationSettings is absent', () async {
      when(() => mockDio.get<Map<String, dynamic>>('v1/me')).thenAnswer(
        (_) async =>
            _ok<Map<String, dynamic>>('v1/me', <String, dynamic>{'id': 'u1'}),
      );

      final NotificationSettings result = await repo.getNotificationSettings();
      expect(result.push, isTrue);
      expect(result.email, isTrue);
    });
  });

  // ── updateNotificationSettings ──────────────────────────────────────────

  group('updateNotificationSettings', () {
    test('calls PUT v1/me/notification-settings with both fields', () async {
      when(
        () => mockDio.put<dynamic>(
          'v1/me/notification-settings',
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => _voidOk('v1/me/notification-settings'));

      await repo.updateNotificationSettings(push: false, email: true);

      verify(
        () => mockDio.put<dynamic>(
          'v1/me/notification-settings',
          data: any(named: 'data'),
        ),
      ).called(1);
    });
  });

  // ── getSellerStats ──────────────────────────────────────────────────────

  group('getSellerStats', () {
    test('maps numeric and string values into SellerStat entries', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>('v1/me/seller-stats'),
      ).thenAnswer(
        (_) async => _ok<Map<String, dynamic>>(
          'v1/me/seller-stats',
          <String, dynamic>{'totalSales': 42, 'rating': '4.8', 'reviews': 10},
        ),
      );

      final SellerStats result = await repo.getSellerStats();

      expect(result.entries, hasLength(3));
      expect(
        result.entries.map((SellerStat e) => e.label),
        containsAll(<String>['totalSales', 'rating', 'reviews']),
      );
    });

    test('skips non-scalar values (map, list)', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>('v1/me/seller-stats'),
      ).thenAnswer(
        (_) async =>
            _ok<Map<String, dynamic>>('v1/me/seller-stats', <String, dynamic>{
              'totalSales': 5,
              'nested': <String, dynamic>{'a': 1},
            }),
      );

      final SellerStats result = await repo.getSellerStats();
      // 'nested' is a Map — should be skipped.
      expect(result.entries, hasLength(1));
      expect(result.entries.first.label, 'totalSales');
    });
  });

  // ── getBlocked ──────────────────────────────────────────────────────────

  group('getBlocked', () {
    test('maps blocked users from bare list', () async {
      when(() => mockDio.get<dynamic>('v1/me/blocked')).thenAnswer(
        (_) async => _ok<dynamic>('v1/me/blocked', <dynamic>[
          <String, dynamic>{
            'id': 'u2',
            'displayName': 'Bad Actor',
            'avatarUrl': 'https://example.com/avatar.jpg',
          },
        ]),
      );

      final List<BlockedUser> result = await repo.getBlocked();

      expect(result, hasLength(1));
      expect(result.first.id, 'u2');
      expect(result.first.displayName, 'Bad Actor');
      expect(result.first.avatarUrl, isNotNull);
    });

    test('maps blocked users from data envelope', () async {
      when(() => mockDio.get<dynamic>('v1/me/blocked')).thenAnswer(
        (_) async => _ok<dynamic>('v1/me/blocked', <String, dynamic>{
          'data': <dynamic>[
            <String, dynamic>{'uid': 'u3', 'name': 'Spammer'},
          ],
        }),
      );

      final List<BlockedUser> result = await repo.getBlocked();
      expect(result, hasLength(1));
      expect(result.first.id, 'u3');
    });

    test('returns empty when data is null', () async {
      when(
        () => mockDio.get<dynamic>('v1/me/blocked'),
      ).thenAnswer((_) async => _ok<dynamic>('v1/me/blocked', null));

      final List<BlockedUser> result = await repo.getBlocked();
      expect(result, isEmpty);
    });
  });

  // ── block / unblock ─────────────────────────────────────────────────────

  group('block', () {
    test('calls PUT v1/me/blocked/:userId', () async {
      when(
        () => mockDio.put<dynamic>('v1/me/blocked/u2'),
      ).thenAnswer((_) async => _voidOk('v1/me/blocked/u2'));

      await repo.block('u2');

      verify(() => mockDio.put<dynamic>('v1/me/blocked/u2')).called(1);
    });
  });

  group('unblock', () {
    test('calls DELETE v1/me/blocked/:userId', () async {
      when(
        () => mockDio.delete<dynamic>('v1/me/blocked/u2'),
      ).thenAnswer((_) async => _voidOk('v1/me/blocked/u2'));

      await repo.unblock('u2');

      verify(() => mockDio.delete<dynamic>('v1/me/blocked/u2')).called(1);
    });
  });

  // ── deleteAccount ───────────────────────────────────────────────────────

  group('deleteAccount', () {
    test('calls DELETE v1/me', () async {
      when(
        () => mockDio.delete<dynamic>('v1/me'),
      ).thenAnswer((_) async => _voidOk('v1/me'));

      await repo.deleteAccount();

      verify(() => mockDio.delete<dynamic>('v1/me')).called(1);
    });
  });

  // ── updateProfile — social cache invalidation ───────────────────────────

  group('updateProfile', () {
    test('invalidates social cache group on success', () async {
      when(
        () => mockDio.patch<Map<String, dynamic>>(
          'v1/me',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => _ok<Map<String, dynamic>>('v1/me', <String, dynamic>{
          'id': 'u1',
          'firstName': 'Updated',
        }),
      );

      await repo.updateProfile(firstName: 'Updated');

      verify(() => mockCache.invalidateGroup('social')).called(1);
    });

    test('returns updated MeProfile', () async {
      when(
        () => mockDio.patch<Map<String, dynamic>>(
          'v1/me',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => _ok<Map<String, dynamic>>('v1/me', <String, dynamic>{
          'id': 'u1',
          'firstName': 'Jane',
          'lastName': 'Doe',
          'hasAddress': true,
        }),
      );

      final MeProfile result = await repo.updateProfile(firstName: 'Jane');

      expect(result.id, 'u1');
      expect(result.firstName, 'Jane');
      expect(result.hasAddress, isTrue);
    });
  });

  // ── _mapProfile edge cases ──────────────────────────────────────────────

  group('_mapProfile — sellerRole', () {
    test('maps PARTICULAR role', () async {
      when(() => mockDio.get<Map<String, dynamic>>('v1/me')).thenAnswer(
        (_) async => _ok<Map<String, dynamic>>('v1/me', <String, dynamic>{
          'id': 'u1',
          'sellerRole': 'PARTICULAR',
        }),
      );

      final MeProfile profile = await repo.getMe();
      expect(profile.sellerRole, SellerRole.particular);
    });

    test('maps VENDOR role', () async {
      when(() => mockDio.get<Map<String, dynamic>>('v1/me')).thenAnswer(
        (_) async => _ok<Map<String, dynamic>>('v1/me', <String, dynamic>{
          'id': 'u1',
          'role': 'VENDOR',
        }),
      );

      final MeProfile profile = await repo.getMe();
      expect(profile.sellerRole, SellerRole.vendor);
    });

    test(
      'profile with hasAddress inferred from non-empty address map',
      () async {
        when(() => mockDio.get<Map<String, dynamic>>('v1/me')).thenAnswer(
          (_) async => _ok<Map<String, dynamic>>('v1/me', <String, dynamic>{
            'id': 'u1',
            'address': <String, dynamic>{'line1': '1 Main St'},
          }),
        );

        final MeProfile profile = await repo.getMe();
        expect(profile.hasAddress, isTrue);
      },
    );

    test('_unwrap with wrapped data key', () async {
      when(() => mockDio.get<Map<String, dynamic>>('v1/me')).thenAnswer(
        (_) async => _ok<Map<String, dynamic>>('v1/me', <String, dynamic>{
          'data': <String, dynamic>{'id': 'u5', 'firstName': 'Wrapped'},
        }),
      );

      final MeProfile profile = await repo.getMe();
      expect(profile.id, 'u5');
      expect(profile.firstName, 'Wrapped');
    });
  });
}
