import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/me/entity/blocked_user.dart';

void main() {
  group('BlockedUser', () {
    const BlockedUser user = BlockedUser(
      id: 'u1',
      displayName: 'Spammer',
      avatarUrl: 'https://example.com/spam.jpg',
    );

    test('getters return constructor values', () {
      expect(user.id, 'u1');
      expect(user.displayName, 'Spammer');
      expect(user.avatarUrl, 'https://example.com/spam.jpg');
    });

    test('name getter returns displayName', () {
      expect(user.name, 'Spammer');
    });

    test('optional fields default to empty / null', () {
      const BlockedUser minimal = BlockedUser(id: 'u2');
      expect(minimal.displayName, '');
      expect(minimal.avatarUrl, isNull);
    });

    test('two instances with same fields are equal', () {
      const BlockedUser other = BlockedUser(
        id: 'u1',
        displayName: 'Spammer',
        avatarUrl: 'https://example.com/spam.jpg',
      );
      expect(user, equals(other));
      expect(user.hashCode, equals(other.hashCode));
    });

    test('instances with different id are not equal', () {
      const BlockedUser other = BlockedUser(id: 'u-X');
      expect(user, isNot(equals(other)));
    });
  });
}
