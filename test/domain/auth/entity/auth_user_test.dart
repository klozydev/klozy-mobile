import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/auth/entity/auth_user.dart';

void main() {
  group('AuthUser', () {
    const AuthUser full = AuthUser(
      uid: 'uid-1',
      email: 'user@example.com',
      phoneNumber: '+971501234567',
      displayName: 'Alice',
      photoUrl: 'https://example.com/photo.jpg',
      emailVerified: true,
    );

    const AuthUser minimal = AuthUser(uid: 'uid-2');

    test('getters return the values passed in the constructor', () {
      expect(full.uid, 'uid-1');
      expect(full.email, 'user@example.com');
      expect(full.phoneNumber, '+971501234567');
      expect(full.displayName, 'Alice');
      expect(full.photoUrl, 'https://example.com/photo.jpg');
      expect(full.emailVerified, isTrue);
    });

    test('optional fields default to null / false', () {
      expect(minimal.email, isNull);
      expect(minimal.phoneNumber, isNull);
      expect(minimal.displayName, isNull);
      expect(minimal.photoUrl, isNull);
      expect(minimal.emailVerified, isFalse);
    });

    test('two instances with same fields are equal', () {
      const AuthUser other = AuthUser(
        uid: 'uid-1',
        email: 'user@example.com',
        phoneNumber: '+971501234567',
        displayName: 'Alice',
        photoUrl: 'https://example.com/photo.jpg',
        emailVerified: true,
      );
      expect(full, equals(other));
      expect(full.hashCode, equals(other.hashCode));
    });

    test('instances with different uid are not equal', () {
      const AuthUser other = AuthUser(uid: 'uid-X');
      expect(minimal, isNot(equals(other)));
    });
  });
}
