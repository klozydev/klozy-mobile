import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/reels/domain/entity/reel_comment.dart';

void main() {
  final DateTime ts = DateTime(2024, 4, 5);

  group('ReelComment', () {
    final ReelComment comment = ReelComment(
      id: 'c1',
      body: 'Love this look!',
      authorId: 'u1',
      authorName: 'Dana',
      authorAvatar: 'https://example.com/dana.jpg',
      createdAt: ts,
    );

    test('getters return constructor values', () {
      expect(comment.id, 'c1');
      expect(comment.body, 'Love this look!');
      expect(comment.authorId, 'u1');
      expect(comment.authorName, 'Dana');
      expect(comment.authorAvatar, 'https://example.com/dana.jpg');
      expect(comment.createdAt, ts);
    });

    test('optional fields default to empty / null', () {
      const ReelComment minimal = ReelComment(id: 'c2', body: 'Nice');
      expect(minimal.authorId, '');
      expect(minimal.authorName, '');
      expect(minimal.authorAvatar, isNull);
      expect(minimal.createdAt, isNull);
    });

    test('two instances with same fields are equal', () {
      final ReelComment other = ReelComment(
        id: 'c1',
        body: 'Love this look!',
        authorId: 'u1',
        authorName: 'Dana',
        authorAvatar: 'https://example.com/dana.jpg',
        createdAt: ts,
      );
      expect(comment, equals(other));
      expect(comment.hashCode, equals(other.hashCode));
    });

    test('instances with different id are not equal', () {
      const ReelComment other = ReelComment(id: 'c-X', body: 'Nice');
      expect(comment, isNot(equals(other)));
    });
  });
}
