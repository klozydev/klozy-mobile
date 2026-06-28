// test/data/social/social_repository_impl_test.dart

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/core/network/cache/session_cache.dart';
import 'package:klozy/src/data/social/social_repository_impl.dart';
import 'package:klozy/src/domain/me/entity/me_profile.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:klozy/src/domain/product/entity/product.dart';
import 'package:klozy/src/domain/social/entity/follow_user.dart';
import 'package:klozy/src/domain/social/entity/profile_reel.dart';
import 'package:klozy/src/domain/social/entity/social_profile.dart';
import 'package:klozy/src/domain/social/entity/user_review.dart';
import 'package:mocktail/mocktail.dart';

// ── Mocks ──────────────────────────────────────────────────────────────────

class _MockDio extends Mock implements Dio {}

class _MockMeRepository extends Mock implements MeRepository {}

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

Map<String, dynamic> _profileJson({String id = 'u1'}) => <String, dynamic>{
  'id': id,
  'displayName': 'Alice',
  'avatarUrl': 'https://example.com/alice.jpg',
  'bio': 'Fashion lover',
  'isPro': false,
  'isFollowing': false,
  'isMe': false,
};

Map<String, dynamic> _productJson({String id = 'p1'}) => <String, dynamic>{
  'id': id,
  'title': 'Item $id',
  'price': 50,
};

void main() {
  late _MockDio mockDio;
  late _MockMeRepository mockMe;
  late _MockSessionCache mockCache;
  late SocialRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(Options());
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    mockDio = _MockDio();
    mockMe = _MockMeRepository();
    mockCache = _MockSessionCache();
    when(() => mockCache.invalidateGroup(any())).thenAnswer((_) {});
    repo = SocialRepositoryImpl(mockDio, mockMe, mockCache);
  });

  // ── getProfile ───────────────────────────────────────────────────────────

  group('getProfile', () {
    test('maps SocialProfile from GET /v1/users/:id', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          'v1/users/u1',
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => _ok<Map<String, dynamic>>('v1/users/u1', _profileJson()),
      );

      final SocialProfile result = await repo.getProfile('u1');

      expect(result.id, 'u1');
      expect(result.displayName, 'Alice');
      expect(result.avatarUrl, isNotNull);
      expect(result.isFollowing, isFalse);
    });

    test('unwraps data envelope', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          'v1/users/u2',
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => _ok<Map<String, dynamic>>('v1/users/u2', <String, dynamic>{
          'data': <String, dynamic>{'id': 'u2', 'displayName': 'Bob'},
        }),
      );

      final SocialProfile result = await repo.getProfile('u2');
      expect(result.id, 'u2');
      expect(result.displayName, 'Bob');
    });
  });

  // ── getMyProfile ─────────────────────────────────────────────────────────

  group('getMyProfile', () {
    test('delegates to getProfile with current user id', () async {
      when(() => mockMe.getMe()).thenAnswer(
        (_) async =>
            const MeProfile(id: 'me-id', firstName: 'Jane', lastName: 'Doe'),
      );
      when(
        () => mockDio.get<Map<String, dynamic>>(
          'v1/users/me-id',
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => _ok<Map<String, dynamic>>(
          'v1/users/me-id',
          _profileJson(id: 'me-id'),
        ),
      );

      final SocialProfile result = await repo.getMyProfile();

      expect(result.id, 'me-id');
      verify(() => mockMe.getMe()).called(1);
    });
  });

  // ── getUserProducts ──────────────────────────────────────────────────────

  group('getUserProducts', () {
    test('maps product list from bare list', () async {
      when(
        () => mockDio.get<dynamic>(
          'v1/users/u1/products',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => _ok<dynamic>('v1/users/u1/products', <dynamic>[
          _productJson(id: 'p1'),
          _productJson(id: 'p2'),
        ]),
      );

      final List<Product> result = await repo.getUserProducts('u1');

      expect(result, hasLength(2));
      expect(result[0].id, 'p1');
      expect(result[1].id, 'p2');
    });

    test('maps product list from data envelope', () async {
      when(
        () => mockDio.get<dynamic>(
          'v1/users/u2/products',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => _ok<dynamic>('v1/users/u2/products', <String, dynamic>{
          'data': <dynamic>[_productJson(id: 'p3')],
        }),
      );

      final List<Product> result = await repo.getUserProducts('u2');
      expect(result.first.id, 'p3');
    });
  });

  // ── getUserReels ─────────────────────────────────────────────────────────

  group('getUserReels', () {
    test('calls v1/reels/mine when mine=true', () async {
      when(
        () => mockDio.get<dynamic>(
          'v1/reels/mine',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => _ok<dynamic>('v1/reels/mine', <dynamic>[
          <String, dynamic>{'id': 'r1'},
        ]),
      );

      final List<ProfileReel> result = await repo.getUserReels(
        'u1',
        mine: true,
      );

      expect(result, hasLength(1));
      expect(result.first.id, 'r1');
      verify(
        () => mockDio.get<dynamic>(
          'v1/reels/mine',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).called(1);
    });

    test('calls v1/reels with authorId when mine=false', () async {
      when(
        () => mockDio.get<dynamic>(
          'v1/reels',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => _ok<dynamic>('v1/reels', <dynamic>[
          <String, dynamic>{'id': 'r2'},
        ]),
      );

      final List<ProfileReel> result = await repo.getUserReels(
        'u2',
        mine: false,
      );

      expect(result, hasLength(1));
      final VerificationResult v = verify(
        () => mockDio.get<dynamic>(
          'v1/reels',
          queryParameters: captureAny(named: 'queryParameters'),
        ),
      );
      final Map<String, dynamic> params =
          v.captured.first as Map<String, dynamic>;
      expect(params['authorId'], 'u2');
    });
  });

  // ── getReviews ───────────────────────────────────────────────────────────

  group('getReviews', () {
    test('maps user reviews list', () async {
      when(
        () => mockDio.get<dynamic>(
          'v1/users/u1/reviews',
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => _ok<dynamic>('v1/users/u1/reviews', <dynamic>[
          <String, dynamic>{
            'id': 'rev1',
            'rating': 5,
            'body': 'Excellent!',
            'author': <String, dynamic>{'displayName': 'Reviewer'},
          },
        ]),
      );

      final List<UserReview> result = await repo.getReviews('u1');

      expect(result, hasLength(1));
      expect(result.first.id, 'rev1');
      expect(result.first.rating, 5.0);
      expect(result.first.body, 'Excellent!');
    });

    test('returns empty list on error (swallowed)', () async {
      when(
        () => mockDio.get<dynamic>(
          'v1/users/u2/reviews',
          options: any(named: 'options'),
        ),
      ).thenThrow(Exception('network error'));

      final List<UserReview> result = await repo.getReviews('u2');
      expect(result, isEmpty);
    });
  });

  // ── getFollowers ─────────────────────────────────────────────────────────

  group('getFollowers', () {
    test('maps followers list', () async {
      when(
        () => mockDio.get<dynamic>(
          'v1/users/u1/followers',
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => _ok<dynamic>('v1/users/u1/followers', <dynamic>[
          <String, dynamic>{
            'id': 'fu1',
            'displayName': 'Follower',
            'isPro': false,
            'isFollowing': true,
          },
        ]),
      );

      final List<FollowUser> result = await repo.getFollowers('u1');

      expect(result, hasLength(1));
      expect(result.first.id, 'fu1');
      expect(result.first.isFollowing, isTrue);
    });
  });

  // ── getFollowing ─────────────────────────────────────────────────────────

  group('getFollowing', () {
    test('maps following list', () async {
      when(
        () => mockDio.get<dynamic>(
          'v1/users/u1/following',
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => _ok<dynamic>('v1/users/u1/following', <dynamic>[
          <String, dynamic>{'id': 'fu2', 'displayName': 'Following User'},
        ]),
      );

      final List<FollowUser> result = await repo.getFollowing('u1');

      expect(result, hasLength(1));
      expect(result.first.id, 'fu2');
    });
  });

  // ── follow ───────────────────────────────────────────────────────────────

  group('follow', () {
    test('calls PUT and invalidates social cache', () async {
      when(
        () => mockDio.put<dynamic>('v1/users/u2/follow'),
      ).thenAnswer((_) async => _voidOk('v1/users/u2/follow'));

      await repo.follow('u2');

      verify(() => mockDio.put<dynamic>('v1/users/u2/follow')).called(1);
      verify(() => mockCache.invalidateGroup('social')).called(1);
    });
  });

  // ── unfollow ─────────────────────────────────────────────────────────────

  group('unfollow', () {
    test('calls DELETE and invalidates social cache', () async {
      when(
        () => mockDio.delete<dynamic>('v1/users/u2/follow'),
      ).thenAnswer((_) async => _voidOk('v1/users/u2/follow'));

      await repo.unfollow('u2');

      verify(() => mockDio.delete<dynamic>('v1/users/u2/follow')).called(1);
      verify(() => mockCache.invalidateGroup('social')).called(1);
    });
  });

  // ── reportUser ───────────────────────────────────────────────────────────

  group('reportUser', () {
    test('posts reason and invalidates social cache', () async {
      when(
        () => mockDio.post<dynamic>(
          'v1/users/u3/report',
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => _voidOk('v1/users/u3/report'));

      await repo.reportUser('u3', 'spam');

      final VerificationResult v = verify(
        () => mockDio.post<dynamic>(
          'v1/users/u3/report',
          data: captureAny(named: 'data'),
        ),
      );
      final Map<String, dynamic> body =
          v.captured.first as Map<String, dynamic>;
      expect(body['reason'], 'spam');
      verify(() => mockCache.invalidateGroup('social')).called(1);
    });
  });
}
