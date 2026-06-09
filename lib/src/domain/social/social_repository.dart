import 'package:klozy/src/domain/product/entity/product.dart';
import 'package:klozy/src/domain/social/entity/follow_user.dart';
import 'package:klozy/src/domain/social/entity/profile_reel.dart';
import 'package:klozy/src/domain/social/entity/social_profile.dart';
import 'package:klozy/src/domain/social/entity/user_review.dart';

/// Profiles + follow graph (`/v1/users`).
abstract class SocialRepository {
  /// `GET /v1/users/{id}` — public/self profile (stats + isFollowing/isMe).
  Future<SocialProfile> getProfile(String userId);

  /// My own profile (resolves my id from `/v1/me` then `getProfile`).
  Future<SocialProfile> getMyProfile();

  /// `GET /v1/users/{id}/products` — a user's active listings.
  Future<List<Product>> getUserProducts(String userId, {int page = 1});

  /// `GET /v1/reels?authorId={id}` — a user's reels (thumbnails).
  Future<List<ProfileReel>> getUserReels(String userId);

  /// `GET /v1/users/{id}/reviews` — reviews for the user (best-effort).
  Future<List<UserReview>> getReviews(String userId);

  /// `GET /v1/users/{id}/followers`.
  Future<List<FollowUser>> getFollowers(String userId);

  /// `GET /v1/users/{id}/following`.
  Future<List<FollowUser>> getFollowing(String userId);

  /// `PUT /v1/users/{id}/follow`.
  Future<void> follow(String userId);

  /// `DELETE /v1/users/{id}/follow`.
  Future<void> unfollow(String userId);

  /// `POST /v1/users/{id}/report`.
  Future<void> reportUser(String userId, String reason);
}
