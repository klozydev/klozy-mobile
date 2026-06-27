import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/data/social/social_mapper.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Map<String, dynamic> _profileJson({
  String id = 'user-1',
  String firebaseUid = 'fbuid-1',
  String displayName = 'Alice',
  String? avatarUrl = 'https://cdn.example.com/alice.jpg',
  String? bio = 'I love fashion',
  bool isPro = true,
  bool isFollowing = false,
  bool isMe = false,
  double rating = 4.5,
  int reviewCount = 10,
  int followers = 200,
  int following = 50,
  int listings = 30,
  String? location = 'Paris',
}) => <String, dynamic>{
  'id': id,
  'firebaseUid': firebaseUid,
  'displayName': displayName,
  if (avatarUrl != null) 'avatarUrl': avatarUrl,
  if (bio != null) 'bio': bio,
  'isPro': isPro,
  'isFollowing': isFollowing,
  'isMe': isMe,
  'counts': <String, dynamic>{
    'rating': rating,
    'reviewCount': reviewCount,
    'followers': followers,
    'following': following,
    'listings': listings,
  },
  if (location != null) 'location': location,
};

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // mapSocialProfile
  // -------------------------------------------------------------------------

  group('mapSocialProfile — null/empty input', () {
    test('null returns safe defaults', () {
      final p = mapSocialProfile(null);
      expect(p.id, isEmpty);
      expect(p.displayName, isEmpty);
      expect(p.rating, 0);
      expect(p.followers, 0);
    });

    test('empty map returns safe defaults', () {
      final p = mapSocialProfile(const <String, dynamic>{});
      expect(p.id, isEmpty);
    });
  });

  group('mapSocialProfile — standard fields', () {
    late final dynamic p;
    setUpAll(() => p = mapSocialProfile(_profileJson()));

    test('id', () => expect(p.id, 'user-1'));
    test('firebaseUid', () => expect(p.firebaseUid, 'fbuid-1'));
    test('displayName', () => expect(p.displayName, 'Alice'));
    test(
      'avatarUrl',
      () => expect(p.avatarUrl, 'https://cdn.example.com/alice.jpg'),
    );
    test('bio', () => expect(p.bio, 'I love fashion'));
    test('isPro', () => expect(p.isPro, isTrue));
    test('isFollowing', () => expect(p.isFollowing, isFalse));
    test('isMe', () => expect(p.isMe, isFalse));
    test('rating', () => expect(p.rating, closeTo(4.5, 0.001)));
    test('reviewCount', () => expect(p.reviewCount, 10));
    test('followers', () => expect(p.followers, 200));
    test('following', () => expect(p.following, 50));
    test('listingsCount', () => expect(p.listingsCount, 30));
    test('location', () => expect(p.location, 'Paris'));
  });

  group('mapSocialProfile — data envelope', () {
    test('unwraps data key', () {
      final p = mapSocialProfile(<String, dynamic>{'data': _profileJson()});
      expect(p.id, 'user-1');
    });
  });

  group('mapSocialProfile — id alternatives', () {
    test('reads _id when id absent', () {
      final json = Map<String, dynamic>.from(_profileJson())
        ..remove('id')
        ..['_id'] = 'alt-id';
      expect(mapSocialProfile(json).id, 'alt-id');
    });

    test('reads uid when id and _id absent', () {
      final json = Map<String, dynamic>.from(_profileJson())
        ..remove('id')
        ..['uid'] = 'uid-val';
      expect(mapSocialProfile(json).id, 'uid-val');
    });
  });

  group('mapSocialProfile — isFollowing alternatives', () {
    test('isFollowing via following key', () {
      final json = Map<String, dynamic>.from(_profileJson())
        ..remove('isFollowing')
        ..['following'] = true;
      expect(mapSocialProfile(json).isFollowing, isTrue);
    });
  });

  group('mapSocialProfile — isMe alternatives', () {
    test('isMe via isSelf key', () {
      final json = Map<String, dynamic>.from(_profileJson())
        ..remove('isMe')
        ..['isSelf'] = true;
      expect(mapSocialProfile(json).isMe, isTrue);
    });
  });

  group('mapSocialProfile — isPro via pro key', () {
    test('isPro via pro key', () {
      final json = Map<String, dynamic>.from(_profileJson())
        ..remove('isPro')
        ..['pro'] = true;
      expect(mapSocialProfile(json).isPro, isTrue);
    });
  });

  group('mapSocialProfile — stats key', () {
    test('reads from stats sub-object when present', () {
      final json = <String, dynamic>{
        'id': 'u2',
        'displayName': 'Bob',
        'stats': <String, dynamic>{
          'avgRating': 3.8,
          'ratingCount': 5,
          'followersCount': 100,
          'followingCount': 20,
          'listingsCount': 8,
        },
      };
      final p = mapSocialProfile(json);
      expect(p.rating, closeTo(3.8, 0.001));
      expect(p.reviewCount, 5);
      expect(p.followers, 100);
      expect(p.following, 20);
      expect(p.listingsCount, 8);
    });
  });

  group('mapSocialProfile — displayName alternatives', () {
    test('falls back to name key', () {
      final json = Map<String, dynamic>.from(_profileJson())
        ..remove('displayName')
        ..['name'] = 'Charlie';
      expect(mapSocialProfile(json).displayName, 'Charlie');
    });

    test('falls back to firstName key', () {
      final json = Map<String, dynamic>.from(_profileJson())
        ..remove('displayName')
        ..['firstName'] = 'Diana';
      expect(mapSocialProfile(json).displayName, 'Diana');
    });
  });

  group('mapSocialProfile — optional null fields', () {
    test('avatarUrl null when absent', () {
      final json = Map<String, dynamic>.from(_profileJson())
        ..remove('avatarUrl');
      expect(mapSocialProfile(json).avatarUrl, isNull);
    });

    test('bio null when absent', () {
      final json = Map<String, dynamic>.from(_profileJson())..remove('bio');
      expect(mapSocialProfile(json).bio, isNull);
    });

    test('location null when absent', () {
      final json = Map<String, dynamic>.from(_profileJson())
        ..remove('location');
      expect(mapSocialProfile(json).location, isNull);
    });
  });

  // -------------------------------------------------------------------------
  // mapFollowUser
  // -------------------------------------------------------------------------

  group('mapFollowUser — standard fields', () {
    test('maps all fields correctly', () {
      final u = mapFollowUser(<String, dynamic>{
        'id': 'fu-1',
        'displayName': 'Eve',
        'avatarUrl': 'https://cdn.example.com/eve.jpg',
        'isPro': true,
        'isFollowing': true,
      });
      expect(u.id, 'fu-1');
      expect(u.displayName, 'Eve');
      expect(u.avatarUrl, 'https://cdn.example.com/eve.jpg');
      expect(u.isPro, isTrue);
      expect(u.isFollowing, isTrue);
    });

    test('null input returns safe defaults', () {
      final u = mapFollowUser(null);
      expect(u.id, isEmpty);
      expect(u.displayName, isEmpty);
      expect(u.avatarUrl, isNull);
      expect(u.isPro, isFalse);
      expect(u.isFollowing, isFalse);
    });
  });

  group('mapFollowUser — alternatives', () {
    test('id from _id', () {
      final u = mapFollowUser(<String, dynamic>{
        '_id': 'x',
        'displayName': 'F',
      });
      expect(u.id, 'x');
    });

    test('displayName from name', () {
      final u = mapFollowUser(<String, dynamic>{'id': 'y', 'name': 'G'});
      expect(u.displayName, 'G');
    });

    test('avatarUrl from avatar key', () {
      final u = mapFollowUser(<String, dynamic>{
        'id': 'z',
        'avatar': 'https://cdn.example.com/z.jpg',
      });
      expect(u.avatarUrl, 'https://cdn.example.com/z.jpg');
    });

    test('avatarUrl from photoUrl key', () {
      final u = mapFollowUser(<String, dynamic>{
        'id': 'z',
        'photoUrl': 'https://cdn.example.com/photo.jpg',
      });
      expect(u.avatarUrl, 'https://cdn.example.com/photo.jpg');
    });

    test('isPro from pro key', () {
      final u = mapFollowUser(<String, dynamic>{'id': 'a', 'pro': true});
      expect(u.isPro, isTrue);
    });

    test('isFollowing from following key', () {
      final u = mapFollowUser(<String, dynamic>{'id': 'b', 'following': true});
      expect(u.isFollowing, isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // mapProfileReel
  // -------------------------------------------------------------------------

  group('mapProfileReel — standard fields', () {
    test('maps id, thumbnailUrl from playback, and views', () {
      final r = mapProfileReel(<String, dynamic>{
        'id': 'reel-1',
        'playback': <String, dynamic>{
          'thumbnailUrl': 'https://image.mux.com/abc/thumbnail.jpg',
        },
        'views': 1500,
      });
      expect(r.id, 'reel-1');
      expect(r.thumbnailUrl, 'https://image.mux.com/abc/thumbnail.jpg');
      expect(r.views, 1500);
    });

    test('null input returns safe defaults', () {
      final r = mapProfileReel(null);
      expect(r.id, isEmpty);
      expect(r.thumbnailUrl, isNull);
      expect(r.views, 0);
    });
  });

  group('mapProfileReel — thumbnailUrl fallbacks', () {
    test('playback.poster key', () {
      final r = mapProfileReel(<String, dynamic>{
        'id': 'r2',
        'playback': <String, dynamic>{
          'posterUrl': 'https://cdn.example.com/poster.jpg',
        },
      });
      expect(r.thumbnailUrl, 'https://cdn.example.com/poster.jpg');
    });

    test('top-level thumbnailUrl when playback absent', () {
      final r = mapProfileReel(<String, dynamic>{
        'id': 'r3',
        'thumbnailUrl': 'https://cdn.example.com/top.jpg',
      });
      expect(r.thumbnailUrl, 'https://cdn.example.com/top.jpg');
    });

    test('top-level coverUrl key', () {
      final r = mapProfileReel(<String, dynamic>{
        'id': 'r4',
        'coverUrl': 'https://cdn.example.com/cover.jpg',
      });
      expect(r.thumbnailUrl, 'https://cdn.example.com/cover.jpg');
    });

    test('_id alternative', () {
      final r = mapProfileReel(<String, dynamic>{'_id': 'alt-reel'});
      expect(r.id, 'alt-reel');
    });

    test('viewCount key', () {
      final r = mapProfileReel(<String, dynamic>{'id': 'x', 'viewCount': 42});
      expect(r.views, 42);
    });
  });

  // -------------------------------------------------------------------------
  // mapUserReview
  // -------------------------------------------------------------------------

  group('mapUserReview — standard fields', () {
    test('maps all fields correctly with author sub-object', () {
      final rv = mapUserReview(<String, dynamic>{
        'id': 'rev-1',
        'author': <String, dynamic>{
          'displayName': 'Frank',
          'avatarUrl': 'https://cdn.example.com/frank.jpg',
        },
        'rating': 4.0,
        'body': 'Great seller!',
        'createdAt': '2024-03-01T10:00:00.000Z',
      });
      expect(rv.id, 'rev-1');
      expect(rv.authorName, 'Frank');
      expect(rv.authorAvatar, 'https://cdn.example.com/frank.jpg');
      expect(rv.rating, closeTo(4.0, 0.001));
      expect(rv.body, 'Great seller!');
      expect(rv.createdAt, isNotNull);
    });

    test('null input returns safe defaults', () {
      final rv = mapUserReview(null);
      expect(rv.id, isEmpty);
      expect(rv.authorName, isEmpty);
      expect(rv.body, isEmpty);
      expect(rv.rating, 0);
      expect(rv.createdAt, isNull);
    });
  });

  group('mapUserReview — reviewer key', () {
    test('reads from reviewer key when author absent', () {
      final rv = mapUserReview(<String, dynamic>{
        'id': 'rev-2',
        'reviewer': <String, dynamic>{'name': 'Grace'},
        'rating': 3,
        'text': 'Decent.',
      });
      expect(rv.authorName, 'Grace');
      expect(rv.body, 'Decent.');
    });
  });

  group('mapUserReview — body alternatives', () {
    test('text key', () {
      final rv = mapUserReview(<String, dynamic>{
        'id': 'r',
        'body': '',
        'text': 'Good!',
      });
      // body is '' which is empty → text wins? Actually _str returns null for empty
      // strings, so 'body' = '' means it reads 'text'.
      expect(rv.body, 'Good!');
    });

    test('comment key', () {
      final rv = mapUserReview(<String, dynamic>{
        'id': 'r',
        'comment': 'Super!',
      });
      expect(rv.body, 'Super!');
    });
  });

  group('mapUserReview — stars key for rating', () {
    test('stars key', () {
      final rv = mapUserReview(<String, dynamic>{'id': 'x', 'stars': 5});
      expect(rv.rating, closeTo(5.0, 0.001));
    });
  });

  group('mapUserReview — createdAt alternatives', () {
    test('created key', () {
      final rv = mapUserReview(<String, dynamic>{
        'id': 'x',
        'created': '2024-06-01T00:00:00.000Z',
      });
      expect(rv.createdAt, isNotNull);
      expect(rv.createdAt!.year, 2024);
    });

    test('invalid date → null', () {
      final rv = mapUserReview(<String, dynamic>{
        'id': 'x',
        'createdAt': 'not-a-date',
      });
      expect(rv.createdAt, isNull);
    });
  });
}
