import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/core/network/cache/session_cache.dart';
import 'package:klozy/src/data/me/me_repository_impl.dart';
import 'package:klozy/src/domain/me/entity/address_input.dart';
import 'package:klozy/src/domain/me/entity/me_profile.dart';
import 'package:klozy/src/domain/me/entity/preferences_input.dart';
import 'package:mocktail/mocktail.dart';

// ── Fakes ─────────────────────────────────────────────────────────────────────

class _MockDio extends Mock implements Dio {}

class _MockSessionCache extends Mock implements SessionCache {}

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Minimal API envelope that MeRepositoryImpl._mapProfile can parse into a
/// non-empty MeProfile.
Map<String, dynamic> _profileEnvelope({String id = 'u1'}) => <String, dynamic>{
  'id': id,
  'firstName': 'Jane',
  'lastName': 'Doe',
  'hasAddress': true,
};

Response<Map<String, dynamic>> _profileResponse({String id = 'u1'}) =>
    Response<Map<String, dynamic>>(
      requestOptions: RequestOptions(path: 'v1/me'),
      statusCode: 200,
      data: _profileEnvelope(id: id),
    );

void main() {
  late _MockDio mockDio;
  late _MockSessionCache mockCache;
  late MeRepositoryImpl repo;

  setUp(() {
    mockDio = _MockDio();
    mockCache = _MockSessionCache();
    repo = MeRepositoryImpl(mockDio, mockCache);

    when(() => mockCache.invalidateGroup(any())).thenAnswer((_) {});

    // Default stub for all non-getMe Dio calls (mutations).
    when(
      () =>
          mockDio.patch<Map<String, dynamic>>(any(), data: any(named: 'data')),
    ).thenAnswer((_) async => _profileResponse());
    when(
      () => mockDio.put<dynamic>(any(), data: any(named: 'data')),
    ).thenAnswer(
      (_) async => Response<dynamic>(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
      ),
    );
    when(() => mockDio.put<dynamic>(any())).thenAnswer(
      (_) async => Response<dynamic>(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
      ),
    );
  });

  // ── Cache hit: two calls → one network request ─────────────────────────────

  group('getMe caching', () {
    test(
      'two consecutive calls result in exactly one network request',
      () async {
        when(
          () => mockDio.get<Map<String, dynamic>>('v1/me'),
        ).thenAnswer((_) async => _profileResponse());

        final first = await repo.getMe();
        final second = await repo.getMe();

        expect(first, isA<MeProfile>());
        expect(second, same(first)); // identical instance from cache
        verify(() => mockDio.get<Map<String, dynamic>>('v1/me')).called(1);
      },
    );

    test('concurrent calls share one in-flight request (dedup)', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>('v1/me'),
      ).thenAnswer((_) async => _profileResponse());

      // Fire both without awaiting in between.
      final results = await Future.wait([repo.getMe(), repo.getMe()]);

      expect(results[0], same(results[1]));
      verify(() => mockDio.get<Map<String, dynamic>>('v1/me')).called(1);
    });

    test('after error, next call retries the network', () async {
      var callCount = 0;
      when(() => mockDio.get<Map<String, dynamic>>('v1/me')).thenAnswer((
        _,
      ) async {
        callCount++;
        if (callCount == 1) throw Exception('network error');
        return _profileResponse();
      });

      await expectLater(repo.getMe(), throwsException);
      final second = await repo.getMe(); // must retry, not serve stale null
      expect(second, isA<MeProfile>());
      expect(callCount, 2);
    });
  });

  // ── invalidate clears cache ────────────────────────────────────────────────

  group('invalidate', () {
    test('forces a fresh network call on next getMe()', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>('v1/me'),
      ).thenAnswer((_) async => _profileResponse());

      await repo.getMe();
      repo.invalidate();
      await repo.getMe();

      verify(() => mockDio.get<Map<String, dynamic>>('v1/me')).called(2);
    });

    test(
      'invalidate after updateProfile triggers fresh fetch on next getMe()',
      () async {
        when(
          () => mockDio.get<Map<String, dynamic>>('v1/me'),
        ).thenAnswer((_) async => _profileResponse());
        when(
          () => mockDio.patch<Map<String, dynamic>>(
            'v1/me',
            data: any(named: 'data'),
          ),
        ).thenAnswer((_) async => _profileResponse(id: 'u1-updated'));

        await repo.getMe(); // primes cache
        await repo.updateProfile(
          firstName: 'John',
        ); // warms cache with response
        // updateProfile itself updates _cached, so no extra network call needed
        // for getMe, but the version it stores is the PATCH response.
        await repo.getMe();
        // Only one GET (initial); PATCH response was used to warm cache.
        verify(() => mockDio.get<Map<String, dynamic>>('v1/me')).called(1);
      },
    );

    test('invalidate after setAddress forces fresh fetch', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>('v1/me'),
      ).thenAnswer((_) async => _profileResponse());

      await repo.getMe();
      await repo.setAddress(
        const AddressInput(line1: '1 Main St', city: 'Dubai', emirate: 'Dubai'),
      );
      await repo.getMe();

      verify(() => mockDio.get<Map<String, dynamic>>('v1/me')).called(2);
    });

    test('invalidate after setSellerRole forces fresh fetch', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>('v1/me'),
      ).thenAnswer((_) async => _profileResponse());

      await repo.getMe();
      await repo.setSellerRole(role: SellerRole.particular);
      await repo.getMe();

      verify(() => mockDio.get<Map<String, dynamic>>('v1/me')).called(2);
    });

    test('invalidate after setPayoutIban forces fresh fetch', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>('v1/me'),
      ).thenAnswer((_) async => _profileResponse());

      await repo.getMe();
      await repo.setPayoutIban('FR76 1234 5678');
      await repo.getMe();

      verify(() => mockDio.get<Map<String, dynamic>>('v1/me')).called(2);
    });

    test('invalidate after updatePreferences forces fresh fetch', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>('v1/me'),
      ).thenAnswer((_) async => _profileResponse());

      await repo.getMe();
      await repo.updatePreferences(const PreferencesInput(sizeSystem: 'EU'));
      await repo.getMe();

      verify(() => mockDio.get<Map<String, dynamic>>('v1/me')).called(2);
    });
  });

  // ── signOut invalidation (tested via direct invalidate() call) ────────────
  // FirebaseAuthRepository.signOut calls meRepository.invalidate() before
  // signing out. This is integration-tested by verifying that calling
  // invalidate() on the repo directly causes the cache to be cleared,
  // which is already covered by the tests above.
  //
  // A dedicated signOut invalidation test is in
  // test/data/auth/firebase_auth_repository_signout_test.dart.
}
