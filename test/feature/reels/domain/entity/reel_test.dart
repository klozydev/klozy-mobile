import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/reels/domain/entity/reel.dart';
import 'package:klozy/src/feature/reels/domain/entity/reel_author.dart';

void main() {
  const ReelAuthor author = ReelAuthor(
    id: 'a1',
    displayName: 'Alice',
    handle: 'alice',
  );

  group('Reel', () {
    const Reel reel = Reel(
      id: 'r1',
      author: author,
      playbackUrl: 'https://example.com/reel.m3u8',
      posterUrl: 'https://example.com/poster.jpg',
      caption: 'Check out this outfit!',
      likes: 120,
      isLiked: false,
      viewCount: 500,
      taggedCount: 3,
      isReady: true,
    );

    test('getters return constructor values', () {
      expect(reel.id, 'r1');
      expect(reel.author, author);
      expect(reel.playbackUrl, 'https://example.com/reel.m3u8');
      expect(reel.posterUrl, 'https://example.com/poster.jpg');
      expect(reel.caption, 'Check out this outfit!');
      expect(reel.likes, 120);
      expect(reel.isLiked, isFalse);
      expect(reel.viewCount, 500);
      expect(reel.taggedCount, 3);
      expect(reel.isReady, isTrue);
    });

    test('optional fields default to empty / zero / false / true', () {
      const Reel minimal = Reel(id: 'r2', author: author);
      expect(minimal.playbackUrl, isNull);
      expect(minimal.posterUrl, isNull);
      expect(minimal.caption, '');
      expect(minimal.likes, 0);
      expect(minimal.isLiked, isFalse);
      expect(minimal.viewCount, 0);
      expect(minimal.taggedCount, 0);
      expect(minimal.isReady, isTrue);
    });

    test('copyWith changes likes', () {
      final Reel updated = reel.copyWith(likes: 999);
      expect(updated.likes, 999);
      expect(updated.id, reel.id);
      expect(updated.isLiked, reel.isLiked);
    });

    test('copyWith changes isLiked', () {
      final Reel updated = reel.copyWith(isLiked: true);
      expect(updated.isLiked, isTrue);
      expect(updated.likes, reel.likes);
    });

    test('copyWith with no args preserves all fields', () {
      final Reel updated = reel.copyWith();
      expect(updated, equals(reel));
    });

    test('two instances with same fields are equal', () {
      const Reel other = Reel(
        id: 'r1',
        author: author,
        playbackUrl: 'https://example.com/reel.m3u8',
        posterUrl: 'https://example.com/poster.jpg',
        caption: 'Check out this outfit!',
        likes: 120,
        isLiked: false,
        viewCount: 500,
        taggedCount: 3,
        isReady: true,
      );
      expect(reel, equals(other));
      expect(reel.hashCode, equals(other.hashCode));
    });

    test('instances with different id are not equal', () {
      const Reel other = Reel(id: 'r-X', author: author);
      expect(reel, isNot(equals(other)));
    });
  });
}
