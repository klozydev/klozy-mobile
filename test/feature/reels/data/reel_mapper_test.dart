import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/reels/data/reel_mapper.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Map<String, dynamic> _baseReel({
  String id = 'reel-1',
  String? playbackId,
  Map<String, dynamic>? playback,
  String? status,
  String caption = 'My reel',
  Map<String, dynamic>? author,
  int likes = 42,
  bool isLiked = false,
  int viewCount = 1000,
  List<dynamic>? taggedProducts,
}) => <String, dynamic>{
  'id': id,
  if (playbackId != null) 'muxPlaybackId': playbackId,
  if (playback != null) 'playback': playback,
  if (status != null) 'status': status,
  'caption': caption,
  if (author != null) 'author': author,
  'likes': likes,
  'isLiked': isLiked,
  'viewCount': viewCount,
  if (taggedProducts != null) 'taggedProducts': taggedProducts,
};

Map<String, dynamic> _author({
  String id = 'author-1',
  String displayName = 'Alice',
  String? handle = 'alice_style',
  String? avatarUrl = 'https://cdn.example.com/alice.jpg',
  bool isPro = true,
}) => <String, dynamic>{
  'id': id,
  'displayName': displayName,
  if (handle != null) 'handle': handle,
  if (avatarUrl != null) 'avatarUrl': avatarUrl,
  'isPro': isPro,
};

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // mapReel — null/empty
  // -------------------------------------------------------------------------

  group('mapReel — null/empty input', () {
    test('null returns safe defaults', () {
      final reel = mapReel(null);
      expect(reel.id, isEmpty);
      expect(reel.caption, isEmpty);
      expect(reel.likes, 0);
      expect(reel.isLiked, isFalse);
      expect(reel.viewCount, 0);
      expect(reel.taggedCount, 0);
      expect(reel.playbackUrl, isNull);
      expect(reel.posterUrl, isNull);
    });

    test('empty map returns safe defaults', () {
      final reel = mapReel(const <String, dynamic>{});
      expect(reel.id, isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // mapReel — standard fields
  // -------------------------------------------------------------------------

  group('mapReel — standard fields with playback object', () {
    late final dynamic reel;
    setUpAll(
      () => reel = mapReel(
        _baseReel(
          status: 'READY',
          playback: <String, dynamic>{
            'hlsUrl': 'https://stream.mux.com/abc.m3u8',
            'thumbnailUrl': 'https://image.mux.com/abc/thumbnail.jpg',
          },
          author: _author(),
        ),
      ),
    );

    test('id', () => expect(reel.id, 'reel-1'));
    test(
      'playbackUrl from playback.hlsUrl',
      () => expect(reel.playbackUrl, 'https://stream.mux.com/abc.m3u8'),
    );
    test(
      'posterUrl from playback.thumbnailUrl',
      () => expect(reel.posterUrl, 'https://image.mux.com/abc/thumbnail.jpg'),
    );
    test('caption', () => expect(reel.caption, 'My reel'));
    test('likes', () => expect(reel.likes, 42));
    test('isLiked', () => expect(reel.isLiked, isFalse));
    test('viewCount', () => expect(reel.viewCount, 1000));
    test('isReady from READY status', () => expect(reel.isReady, isTrue));
  });

  // -------------------------------------------------------------------------
  // mapReel — playbackUrl from muxPlaybackId
  // -------------------------------------------------------------------------

  group('mapReel — playback URL from muxPlaybackId', () {
    test('constructs Mux HLS URL from muxPlaybackId', () {
      final reel = mapReel(_baseReel(playbackId: 'xyz123', status: 'READY'));
      expect(reel.playbackUrl, 'https://stream.mux.com/xyz123.m3u8');
    });

    test('constructs Mux thumbnail URL from muxPlaybackId', () {
      final reel = mapReel(_baseReel(playbackId: 'xyz123', status: 'READY'));
      expect(reel.posterUrl, 'https://image.mux.com/xyz123/thumbnail.jpg');
    });

    test('playbackId key alternative', () {
      final raw = <String, dynamic>{
        ..._baseReel(status: 'READY'),
        'playbackId': 'pid-abc',
      };
      final reel = mapReel(raw);
      expect(reel.playbackUrl, 'https://stream.mux.com/pid-abc.m3u8');
    });
  });

  // -------------------------------------------------------------------------
  // mapReel — playbackUrl from top-level keys
  // -------------------------------------------------------------------------

  group('mapReel — playbackUrl from top-level keys', () {
    test('top-level playbackUrl', () {
      final raw = <String, dynamic>{
        'id': 'r1',
        'playbackUrl': 'https://cdn.example.com/reel.m3u8',
      };
      expect(mapReel(raw).playbackUrl, 'https://cdn.example.com/reel.m3u8');
    });

    test('top-level hlsUrl', () {
      final raw = <String, dynamic>{
        'id': 'r1',
        'hlsUrl': 'https://cdn.example.com/reel.m3u8',
      };
      expect(mapReel(raw).playbackUrl, 'https://cdn.example.com/reel.m3u8');
    });

    test('top-level posterUrl', () {
      final raw = <String, dynamic>{
        'id': 'r1',
        'posterUrl': 'https://cdn.example.com/poster.jpg',
      };
      expect(mapReel(raw).posterUrl, 'https://cdn.example.com/poster.jpg');
    });
  });

  // -------------------------------------------------------------------------
  // mapReel — isReady logic
  // -------------------------------------------------------------------------

  group('mapReel — isReady', () {
    test('READY status → isReady true', () {
      expect(mapReel(_baseReel(status: 'READY')).isReady, isTrue);
    });

    test('PROCESSING status → isReady false', () {
      expect(mapReel(_baseReel(status: 'PROCESSING')).isReady, isFalse);
    });

    test('no status + non-empty playback object → isReady true', () {
      final raw = <String, dynamic>{
        'id': 'r',
        'playback': <String, dynamic>{'hlsUrl': 'https://s.com/r.m3u8'},
      };
      expect(mapReel(raw).isReady, isTrue);
    });

    test('no status + top-level hlsUrl → isReady true', () {
      final raw = <String, dynamic>{
        'id': 'r',
        'hlsUrl': 'https://s.com/r.m3u8',
      };
      expect(mapReel(raw).isReady, isTrue);
    });

    test('no status + empty playback + no url → isReady false', () {
      expect(mapReel(_baseReel()).isReady, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // mapReel — isLiked alternatives
  // -------------------------------------------------------------------------

  group('mapReel — isLiked', () {
    test('isLiked true', () {
      final raw = <String, dynamic>{..._baseReel(), 'isLiked': true};
      expect(mapReel(raw).isLiked, isTrue);
    });

    test('liked key', () {
      final raw = <String, dynamic>{..._baseReel(), 'liked': true};
      expect(mapReel(raw).isLiked, isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // mapReel — id from _id
  // -------------------------------------------------------------------------

  group('mapReel — _id key', () {
    test('reads _id when id absent', () {
      final raw = <String, dynamic>{'_id': 'alt-reel'};
      expect(mapReel(raw).id, 'alt-reel');
    });
  });

  // -------------------------------------------------------------------------
  // mapReel — views alternatives
  // -------------------------------------------------------------------------

  group('mapReel — views key', () {
    test('views key read', () {
      final raw = <String, dynamic>{'id': 'r', 'views': 500};
      expect(mapReel(raw).viewCount, 500);
    });
  });

  // -------------------------------------------------------------------------
  // mapReel — taggedCount
  // -------------------------------------------------------------------------

  group('mapReel — taggedCount', () {
    test('taggedProducts list → count = length', () {
      final raw = _baseReel(taggedProducts: <dynamic>['p1', 'p2', 'p3']);
      expect(mapReel(raw).taggedCount, 3);
    });

    test('empty taggedProducts list → 0', () {
      final raw = _baseReel(taggedProducts: <dynamic>[]);
      expect(mapReel(raw).taggedCount, 0);
    });

    test('tagged key (alternative)', () {
      final raw = <String, dynamic>{
        'id': 'r',
        'tagged': <dynamic>['a', 'b'],
      };
      expect(mapReel(raw).taggedCount, 2);
    });

    test('taggedCount numeric key', () {
      final raw = <String, dynamic>{'id': 'r', 'taggedCount': 7};
      expect(mapReel(raw).taggedCount, 7);
    });
  });

  // -------------------------------------------------------------------------
  // mapReel — author
  // -------------------------------------------------------------------------

  group('mapReel — author', () {
    test('author mapped from author object', () {
      final reel = mapReel(_baseReel(author: _author()));
      expect(reel.author.id, 'author-1');
      expect(reel.author.displayName, 'Alice');
      expect(reel.author.handle, 'alice_style');
      expect(reel.author.avatarUrl, 'https://cdn.example.com/alice.jpg');
      expect(reel.author.isPro, isTrue);
    });

    test('author defaults when absent', () {
      final reel = mapReel(_baseReel());
      expect(reel.author.id, isEmpty);
      expect(reel.author.displayName, isEmpty);
      expect(reel.author.handle, isNull);
      expect(reel.author.isPro, isFalse);
    });

    test('author id from _id', () {
      final reel = mapReel(
        _baseReel(
          author: <String, dynamic>{'_id': 'alt-author', 'displayName': 'Bob'},
        ),
      );
      expect(reel.author.id, 'alt-author');
    });

    test('author displayName from name', () {
      final reel = mapReel(
        _baseReel(author: <String, dynamic>{'id': 'a', 'name': 'Carol'}),
      );
      expect(reel.author.displayName, 'Carol');
    });

    test('author isPro via pro key', () {
      final reel = mapReel(
        _baseReel(author: <String, dynamic>{'id': 'a', 'pro': true}),
      );
      expect(reel.author.isPro, isTrue);
    });

    test('author handle from username', () {
      final reel = mapReel(
        _baseReel(
          author: <String, dynamic>{'id': 'a', 'username': 'carol_style'},
        ),
      );
      expect(reel.author.handle, 'carol_style');
    });
  });

  // -------------------------------------------------------------------------
  // mapReelComment
  // -------------------------------------------------------------------------

  group('mapReelComment — standard fields', () {
    test('maps all fields with author sub-object', () {
      final c = mapReelComment(<String, dynamic>{
        'id': 'cmt-1',
        'body': 'Nice!',
        'author': <String, dynamic>{
          'id': 'u1',
          'displayName': 'Dave',
          'avatarUrl': 'https://cdn.example.com/dave.jpg',
        },
        'createdAt': '2024-04-15T12:00:00.000Z',
      });
      expect(c.id, 'cmt-1');
      expect(c.body, 'Nice!');
      expect(c.authorId, 'u1');
      expect(c.authorName, 'Dave');
      expect(c.authorAvatar, 'https://cdn.example.com/dave.jpg');
      expect(c.createdAt, isNotNull);
    });

    test('null input returns safe defaults', () {
      final c = mapReelComment(null);
      expect(c.id, isEmpty);
      expect(c.body, isEmpty);
      expect(c.authorId, isEmpty);
      expect(c.authorName, isEmpty);
      expect(c.authorAvatar, isNull);
      expect(c.createdAt, isNull);
    });
  });

  group('mapReelComment — field alternatives', () {
    test('_id key', () {
      final c = mapReelComment(<String, dynamic>{'_id': 'c2', 'body': 'Hi'});
      expect(c.id, 'c2');
    });

    test('text key for body', () {
      final c = mapReelComment(<String, dynamic>{'id': 'c', 'text': 'Hey!'});
      expect(c.body, 'Hey!');
    });

    test('comment key for body', () {
      final c = mapReelComment(<String, dynamic>{'id': 'c', 'comment': 'Wow'});
      expect(c.body, 'Wow');
    });

    test('authorId from top-level authorId when author object absent', () {
      final c = mapReelComment(<String, dynamic>{
        'id': 'c',
        'authorId': 'ua1',
        'body': 'x',
      });
      expect(c.authorId, 'ua1');
    });

    test('author uid key', () {
      final c = mapReelComment(<String, dynamic>{
        'id': 'c',
        'author': <String, dynamic>{'uid': 'uid-99'},
      });
      expect(c.authorId, 'uid-99');
    });

    test('author avatar from avatar key', () {
      final c = mapReelComment(<String, dynamic>{
        'id': 'c',
        'author': <String, dynamic>{'avatar': 'https://cdn.example.com/x.jpg'},
      });
      expect(c.authorAvatar, 'https://cdn.example.com/x.jpg');
    });

    test('created key for createdAt', () {
      final c = mapReelComment(<String, dynamic>{
        'id': 'c',
        'created': '2024-01-01T00:00:00.000Z',
      });
      expect(c.createdAt, isNotNull);
    });

    test('invalid date → null', () {
      final c = mapReelComment(<String, dynamic>{
        'id': 'c',
        'createdAt': 'bad-date',
      });
      expect(c.createdAt, isNull);
    });
  });
}
