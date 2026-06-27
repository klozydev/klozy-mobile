import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/social/entity/social_profile.dart';

void main() {
  const SocialProfile profile = SocialProfile(
    id: 'p1',
    firebaseUid: 'fb-1',
    displayName: 'Bob',
    avatarUrl: 'https://example.com/avatar.jpg',
    bio: 'Fashion lover',
    isPro: true,
    isFollowing: false,
    isMe: false,
    rating: 4.5,
    reviewCount: 10,
    followers: 200,
    following: 50,
    listingsCount: 30,
    location: 'Dubai, UAE',
  );

  group('SocialProfile', () {
    test('getters return constructor values', () {
      expect(profile.id, 'p1');
      expect(profile.firebaseUid, 'fb-1');
      expect(profile.displayName, 'Bob');
      expect(profile.avatarUrl, 'https://example.com/avatar.jpg');
      expect(profile.bio, 'Fashion lover');
      expect(profile.isPro, isTrue);
      expect(profile.isFollowing, isFalse);
      expect(profile.isMe, isFalse);
      expect(profile.rating, 4.5);
      expect(profile.reviewCount, 10);
      expect(profile.followers, 200);
      expect(profile.following, 50);
      expect(profile.listingsCount, 30);
      expect(profile.location, 'Dubai, UAE');
    });

    test('name getter returns displayName', () {
      expect(profile.name, 'Bob');
    });

    test('two instances with same fields are equal', () {
      const SocialProfile other = SocialProfile(
        id: 'p1',
        firebaseUid: 'fb-1',
        displayName: 'Bob',
        avatarUrl: 'https://example.com/avatar.jpg',
        bio: 'Fashion lover',
        isPro: true,
        isFollowing: false,
        isMe: false,
        rating: 4.5,
        reviewCount: 10,
        followers: 200,
        following: 50,
        listingsCount: 30,
        location: 'Dubai, UAE',
      );
      expect(profile, equals(other));
      expect(profile.hashCode, equals(other.hashCode));
    });

    test('instances with different id are not equal', () {
      const SocialProfile other = SocialProfile(id: 'p2');
      expect(profile, isNot(equals(other)));
    });

    test('copyWith changes isFollowing', () {
      final SocialProfile updated = profile.copyWith(isFollowing: true);
      expect(updated.isFollowing, isTrue);
      expect(updated.id, profile.id);
      expect(updated.displayName, profile.displayName);
    });

    test('copyWith changes followers', () {
      final SocialProfile updated = profile.copyWith(followers: 999);
      expect(updated.followers, 999);
      expect(updated.id, profile.id);
    });

    test('copyWith with no args preserves all fields', () {
      final SocialProfile updated = profile.copyWith();
      expect(updated, equals(profile));
    });
  });
}
