// test/feature/reels/data/reels_repository_impl_test.dart

import 'package:event_bus/event_bus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/core/network/cache/session_cache.dart';
import 'package:klozy/src/core/pagination/paginated_list.dart';
import 'package:klozy/src/domain/me/entity/me_profile.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:klozy/src/domain/product/entity/product.dart';
import 'package:klozy/src/feature/reels/data/datasource/remote_reels_data_source.dart';
import 'package:klozy/src/feature/reels/data/reels_repository_impl.dart';
import 'package:klozy/src/feature/reels/domain/entity/reel.dart';
import 'package:klozy/src/feature/reels/domain/entity/reel_comment.dart';
import 'package:klozy/src/feature/reels/domain/reels_repository.dart';
import 'package:mocktail/mocktail.dart';

// ── Mocks ──────────────────────────────────────────────────────────────────

class _MockRemoteReelsDataSource extends Mock
    implements RemoteReelsDataSource {}

class _MockMeRepository extends Mock implements MeRepository {}

class _MockEventBus extends Mock implements EventBus {}

class _MockSessionCache extends Mock implements SessionCache {}

// ── Helpers ────────────────────────────────────────────────────────────────

/// Minimal paginated envelope that PaginatedListResponse can parse.
Map<String, dynamic> _page(List<Map<String, dynamic>> items) =>
    <String, dynamic>{
      'items': items,
      'page': 1,
      'limit': 10,
      'total': items.length,
    };

Map<String, dynamic> _reelJson({String id = 'r1'}) => <String, dynamic>{
  'id': id,
  'caption': 'My reel',
  'author': <String, dynamic>{'id': 'u1', 'displayName': 'Alice'},
  'likes': 5,
  'viewCount': 100,
};

Map<String, dynamic> _commentJson({String id = 'c1'}) => <String, dynamic>{
  'id': id,
  'body': 'Nice reel!',
  'authorId': 'u1',
  'authorName': 'Alice',
};

Map<String, dynamic> _productJson({String id = 'p1'}) => <String, dynamic>{
  'id': id,
  'title': 'Reel product',
  'price': 75,
};

void main() {
  late _MockRemoteReelsDataSource mockRemote;
  late _MockMeRepository mockMe;
  late _MockEventBus mockEventBus;
  late _MockSessionCache mockCache;
  late ReelsRepositoryImpl repo;

  setUp(() {
    mockRemote = _MockRemoteReelsDataSource();
    mockMe = _MockMeRepository();
    mockEventBus = _MockEventBus();
    mockCache = _MockSessionCache();

    when(() => mockEventBus.fire(any())).thenAnswer((_) {});
    when(() => mockCache.invalidateGroup(any())).thenAnswer((_) {});

    repo = ReelsRepositoryImpl(mockRemote, mockMe, mockEventBus, mockCache);
  });

  // ── feed ─────────────────────────────────────────────────────────────────

  group('feed', () {
    test('maps paginated reel list', () async {
      when(
        () => mockRemote.feed(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => _page(<Map<String, dynamic>>[
          _reelJson(id: 'r1'),
          _reelJson(id: 'r2'),
        ]),
      );

      final PaginatedList<Reel> result = await repo.feed();

      expect(result.data, hasLength(2));
      expect(result.data[0].id, 'r1');
      expect(result.data[1].id, 'r2');
    });

    test('passes page and limit to datasource', () async {
      when(
        () => mockRemote.feed(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => _page(<Map<String, dynamic>>[]));

      await repo.feed(page: 3, limit: 5);

      final VerificationResult v = verify(
        () => mockRemote.feed(
          page: captureAny(named: 'page'),
          limit: captureAny(named: 'limit'),
        ),
      );
      expect(v.captured[0], 3);
      expect(v.captured[1], 5);
    });

    test('returns empty list when datasource returns empty page', () async {
      when(
        () => mockRemote.feed(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => <String, dynamic>{});

      final PaginatedList<Reel> result = await repo.feed();
      expect(result.data, isEmpty);
    });
  });

  // ── getReel ───────────────────────────────────────────────────────────────

  group('getReel', () {
    test('maps reel from bare object', () async {
      when(
        () => mockRemote.getOne('r1'),
      ).thenAnswer((_) async => _reelJson(id: 'r1'));

      final Reel result = await repo.getReel('r1');

      expect(result.id, 'r1');
      expect(result.caption, 'My reel');
      expect(result.likes, 5);
    });

    test('unwraps data envelope', () async {
      when(
        () => mockRemote.getOne('r2'),
      ).thenAnswer((_) async => <String, dynamic>{'data': _reelJson(id: 'r2')});

      final Reel result = await repo.getReel('r2');
      expect(result.id, 'r2');
    });
  });

  // ── updateReel ───────────────────────────────────────────────────────────

  group('updateReel', () {
    test('patches caption, invalidates cache, fires event', () async {
      when(() => mockRemote.update(any(), any())).thenAnswer((_) async {});

      await repo.updateReel('r1', caption: 'New caption');

      final VerificationResult v = verify(
        () => mockRemote.update('r1', captureAny()),
      );
      final Map<String, dynamic> body =
          v.captured.first as Map<String, dynamic>;
      expect(body['caption'], 'New caption');
      verify(() => mockCache.invalidateGroup('reels')).called(1);
      verify(() => mockEventBus.fire(any())).called(1);
    });
  });

  // ── like / unlike / view ─────────────────────────────────────────────────

  group('like', () {
    test('delegates to datasource.like', () async {
      when(() => mockRemote.like('r1')).thenAnswer((_) async {});
      await repo.like('r1');
      verify(() => mockRemote.like('r1')).called(1);
    });
  });

  group('unlike', () {
    test('delegates to datasource.unlike', () async {
      when(() => mockRemote.unlike('r1')).thenAnswer((_) async {});
      await repo.unlike('r1');
      verify(() => mockRemote.unlike('r1')).called(1);
    });
  });

  group('view', () {
    test('delegates to datasource.view', () async {
      when(() => mockRemote.view('r1')).thenAnswer((_) async {});
      await repo.view('r1');
      verify(() => mockRemote.view('r1')).called(1);
    });
  });

  // ── report ────────────────────────────────────────────────────────────────

  group('report', () {
    test('delegates to datasource.report', () async {
      when(() => mockRemote.report('r1', any())).thenAnswer((_) async {});
      await repo.report('r1', 'inappropriate');
      verify(() => mockRemote.report('r1', 'inappropriate')).called(1);
    });
  });

  // ── delete ────────────────────────────────────────────────────────────────

  group('delete', () {
    test('delegates, invalidates cache, fires event', () async {
      when(() => mockRemote.delete('r1')).thenAnswer((_) async {});

      await repo.delete('r1');

      verify(() => mockRemote.delete('r1')).called(1);
      verify(() => mockCache.invalidateGroup('reels')).called(1);
      verify(() => mockEventBus.fire(any())).called(1);
    });
  });

  // ── comments ──────────────────────────────────────────────────────────────

  group('comments', () {
    test('maps bare list response', () async {
      when(
        () => mockRemote.comments('r1', page: any(named: 'page')),
      ).thenAnswer(
        (_) async => <dynamic>[_commentJson(id: 'c1'), _commentJson(id: 'c2')],
      );

      final List<ReelComment> result = await repo.comments('r1');

      expect(result, hasLength(2));
      expect(result[0].id, 'c1');
      expect(result[0].body, 'Nice reel!');
    });

    test('maps data envelope list response', () async {
      when(
        () => mockRemote.comments('r1', page: any(named: 'page')),
      ).thenAnswer(
        (_) async => <String, dynamic>{
          'data': <dynamic>[_commentJson(id: 'c3')],
        },
      );

      final List<ReelComment> result = await repo.comments('r1');
      expect(result, hasLength(1));
      expect(result.first.id, 'c3');
    });

    test('maps items envelope list response', () async {
      when(
        () => mockRemote.comments('r2', page: any(named: 'page')),
      ).thenAnswer(
        (_) async => <String, dynamic>{
          'items': <dynamic>[_commentJson(id: 'c4')],
        },
      );

      final List<ReelComment> result = await repo.comments('r2');
      expect(result, hasLength(1));
      expect(result.first.id, 'c4');
    });
  });

  // ── addComment ───────────────────────────────────────────────────────────

  group('addComment', () {
    test('maps new comment from response', () async {
      when(
        () => mockRemote.addComment('r1', any()),
      ).thenAnswer((_) async => _commentJson(id: 'c-new'));

      final ReelComment result = await repo.addComment('r1', 'Great!');

      expect(result.id, 'c-new');
      expect(result.body, 'Nice reel!');
    });
  });

  // ── deleteComment ────────────────────────────────────────────────────────

  group('deleteComment', () {
    test('delegates to datasource', () async {
      when(() => mockRemote.deleteComment('r1', 'c1')).thenAnswer((_) async {});

      await repo.deleteComment('r1', 'c1');

      verify(() => mockRemote.deleteComment('r1', 'c1')).called(1);
    });
  });

  // ── shopTheLook ───────────────────────────────────────────────────────────

  group('shopTheLook', () {
    test('maps product list', () async {
      when(() => mockRemote.shopTheLook('r1')).thenAnswer(
        (_) async => <dynamic>[_productJson(id: 'p1'), _productJson(id: 'p2')],
      );

      final List<Product> result = await repo.shopTheLook('r1');

      expect(result, hasLength(2));
      expect(result[0].id, 'p1');
    });

    test('returns empty list when datasource returns empty', () async {
      when(
        () => mockRemote.shopTheLook('r2'),
      ).thenAnswer((_) async => <dynamic>[]);

      final List<Product> result = await repo.shopTheLook('r2');
      expect(result, isEmpty);
    });
  });

  // ── myProducts ───────────────────────────────────────────────────────────

  group('myProducts', () {
    test('returns empty list when user id is empty', () async {
      when(() => mockMe.getMe()).thenAnswer(
        (_) async =>
            const MeProfile(id: '', firstName: 'Jane', lastName: 'Doe'),
      );

      final List<Product> result = await repo.myProducts();
      expect(result, isEmpty);
      verifyNever(() => mockRemote.userProducts(any()));
    });

    test('returns product list when user is loaded', () async {
      when(() => mockMe.getMe()).thenAnswer(
        (_) async =>
            const MeProfile(id: 'me-1', firstName: 'Jane', lastName: 'Doe'),
      );
      when(
        () => mockRemote.userProducts('me-1'),
      ).thenAnswer((_) async => <dynamic>[_productJson(id: 'p3')]);

      final List<Product> result = await repo.myProducts();

      expect(result, hasLength(1));
      expect(result.first.id, 'p3');
    });
  });

  // ── createReel ────────────────────────────────────────────────────────────

  group('createReel', () {
    test('extracts reelId and uploadUrl from reel + upload keys', () async {
      when(
        () => mockRemote.createReel(
          caption: any(named: 'caption'),
          taggedProductIds: any(named: 'taggedProductIds'),
        ),
      ).thenAnswer(
        (_) async => <String, dynamic>{
          'reel': <String, dynamic>{'id': 'reel-new'},
          'upload': <String, dynamic>{'url': 'https://upload.mux.com/123'},
        },
      );

      final CreatedReel result = await repo.createReel(caption: 'Hello');

      expect(result.reelId, 'reel-new');
      expect(result.uploadUrl, 'https://upload.mux.com/123');
      verify(() => mockCache.invalidateGroup('reels')).called(1);
      verify(() => mockEventBus.fire(any())).called(1);
    });

    test('falls back to top-level id and uploadUrl keys', () async {
      when(
        () => mockRemote.createReel(
          caption: any(named: 'caption'),
          taggedProductIds: any(named: 'taggedProductIds'),
        ),
      ).thenAnswer(
        (_) async => <String, dynamic>{
          '_id': 'reel-flat',
          'uploadUrl': 'https://upload.mux.com/flat',
        },
      );

      final CreatedReel result = await repo.createReel(
        taggedProductIds: <String>['p1'],
      );

      expect(result.reelId, 'reel-flat');
      expect(result.uploadUrl, 'https://upload.mux.com/flat');
    });
  });

  // ── uploadVideo ──────────────────────────────────────────────────────────

  group('uploadVideo', () {
    test('delegates to datasource and fires event', () async {
      when(() => mockRemote.uploadVideo(any(), any())).thenAnswer((_) async {});

      await repo.uploadVideo('https://upload.mux.com/123', '/path/video.mp4');

      verify(
        () => mockRemote.uploadVideo(
          'https://upload.mux.com/123',
          '/path/video.mp4',
        ),
      ).called(1);
      verify(() => mockEventBus.fire(any())).called(1);
    });
  });
}
