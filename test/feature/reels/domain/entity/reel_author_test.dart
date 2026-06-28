import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/reels/domain/entity/reel_author.dart';

void main() {
  group('ReelAuthor', () {
    const ReelAuthor author = ReelAuthor(
      id: 'a1',
      displayName: 'Alice',
      handle: 'alice',
      avatarUrl: 'https://example.com/alice.jpg',
      isPro: true,
    );

    test('getters return constructor values', () {
      expect(author.id, 'a1');
      expect(author.displayName, 'Alice');
      expect(author.handle, 'alice');
      expect(author.avatarUrl, 'https://example.com/alice.jpg');
      expect(author.isPro, isTrue);
    });

    test('label returns @handle when handle is present', () {
      expect(author.label, '@alice');
    });

    test('label returns displayName when handle is null', () {
      const ReelAuthor noHandle = ReelAuthor(id: 'a2', displayName: 'Bob');
      expect(noHandle.label, 'Bob');
    });

    test('label returns displayName when handle is empty string', () {
      const ReelAuthor emptyHandle = ReelAuthor(
        id: 'a3',
        displayName: 'Carol',
        handle: '',
      );
      expect(emptyHandle.label, 'Carol');
    });

    test('optional fields default to empty / null / false', () {
      const ReelAuthor minimal = ReelAuthor(id: 'a4');
      expect(minimal.displayName, '');
      expect(minimal.handle, isNull);
      expect(minimal.avatarUrl, isNull);
      expect(minimal.isPro, isFalse);
    });

    test('two instances with same fields are equal', () {
      const ReelAuthor other = ReelAuthor(
        id: 'a1',
        displayName: 'Alice',
        handle: 'alice',
        avatarUrl: 'https://example.com/alice.jpg',
        isPro: true,
      );
      expect(author, equals(other));
      expect(author.hashCode, equals(other.hashCode));
    });

    test('instances with different id are not equal', () {
      const ReelAuthor other = ReelAuthor(id: 'a-X');
      expect(author, isNot(equals(other)));
    });
  });
}
