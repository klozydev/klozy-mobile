import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/social/entity/follow_user.dart';

void main() {
  const FollowUser user = FollowUser(
    id: 'u1',
    displayName: 'Charlie',
    avatarUrl: 'https://example.com/c.jpg',
    isPro: true,
    isFollowing: false,
  );

  group('FollowUser', () {
    test('getters return constructor values', () {
      expect(user.id, 'u1');
      expect(user.displayName, 'Charlie');
      expect(user.avatarUrl, 'https://example.com/c.jpg');
      expect(user.isPro, isTrue);
      expect(user.isFollowing, isFalse);
    });

    test('name getter returns displayName', () {
      expect(user.name, 'Charlie');
    });

    test('optional fields default to null / false', () {
      const FollowUser minimal = FollowUser(id: 'u2');
      expect(minimal.displayName, '');
      expect(minimal.avatarUrl, isNull);
      expect(minimal.isPro, isFalse);
      expect(minimal.isFollowing, isFalse);
    });

    test('two instances with same fields are equal', () {
      const FollowUser other = FollowUser(
        id: 'u1',
        displayName: 'Charlie',
        avatarUrl: 'https://example.com/c.jpg',
        isPro: true,
        isFollowing: false,
      );
      expect(user, equals(other));
      expect(user.hashCode, equals(other.hashCode));
    });

    test('instances with different id are not equal', () {
      const FollowUser other = FollowUser(id: 'u2');
      expect(user, isNot(equals(other)));
    });

    test('copyWith changes isFollowing', () {
      final FollowUser updated = user.copyWith(isFollowing: true);
      expect(updated.isFollowing, isTrue);
      expect(updated.id, user.id);
      expect(updated.displayName, user.displayName);
    });

    test('copyWith with no args preserves all fields', () {
      final FollowUser updated = user.copyWith();
      expect(updated, equals(user));
    });
  });
}
