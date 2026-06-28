import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/social/entity/user_review.dart';

void main() {
  final DateTime ts = DateTime(2024, 1, 15);

  group('UserReview', () {
    final UserReview review = UserReview(
      id: 'rev-1',
      authorName: 'Dana',
      authorAvatar: 'https://example.com/d.jpg',
      rating: 4.5,
      body: 'Great seller!',
      createdAt: ts,
    );

    test('getters return constructor values', () {
      expect(review.id, 'rev-1');
      expect(review.authorName, 'Dana');
      expect(review.authorAvatar, 'https://example.com/d.jpg');
      expect(review.rating, 4.5);
      expect(review.body, 'Great seller!');
      expect(review.createdAt, ts);
    });

    test('optional fields default to empty / null / zero', () {
      const UserReview minimal = UserReview(id: 'rev-2');
      expect(minimal.authorName, '');
      expect(minimal.authorAvatar, isNull);
      expect(minimal.rating, 0);
      expect(minimal.body, '');
      expect(minimal.createdAt, isNull);
    });

    test('two instances with same fields are equal', () {
      final UserReview other = UserReview(
        id: 'rev-1',
        authorName: 'Dana',
        authorAvatar: 'https://example.com/d.jpg',
        rating: 4.5,
        body: 'Great seller!',
        createdAt: ts,
      );
      expect(review, equals(other));
      expect(review.hashCode, equals(other.hashCode));
    });

    test('instances with different id are not equal', () {
      const UserReview other = UserReview(id: 'rev-X');
      expect(review, isNot(equals(other)));
    });
  });
}
