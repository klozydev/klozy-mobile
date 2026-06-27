import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/social/entity/profile_reel.dart';

void main() {
  group('ProfileReel', () {
    const ProfileReel reel = ProfileReel(
      id: 'r1',
      thumbnailUrl: 'https://example.com/thumb.jpg',
      views: 500,
    );

    test('getters return constructor values', () {
      expect(reel.id, 'r1');
      expect(reel.thumbnailUrl, 'https://example.com/thumb.jpg');
      expect(reel.views, 500);
    });

    test('optional fields default to null / zero', () {
      const ProfileReel minimal = ProfileReel(id: 'r2');
      expect(minimal.thumbnailUrl, isNull);
      expect(minimal.views, 0);
    });

    test('two instances with same fields are equal', () {
      const ProfileReel other = ProfileReel(
        id: 'r1',
        thumbnailUrl: 'https://example.com/thumb.jpg',
        views: 500,
      );
      expect(reel, equals(other));
      expect(reel.hashCode, equals(other.hashCode));
    });

    test('instances with different id are not equal', () {
      const ProfileReel other = ProfileReel(id: 'r99');
      expect(reel, isNot(equals(other)));
    });
  });
}
