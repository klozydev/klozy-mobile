import 'package:klozy/src/domain/social/entity/follow_user.dart';
import 'package:klozy/src/domain/social/entity/profile_reel.dart';
import 'package:klozy/src/domain/social/entity/social_profile.dart';
import 'package:klozy/src/domain/social/entity/user_review.dart';

SocialProfile mapSocialProfile(Object? raw) {
  final json = _obj(raw);
  final inner = json['data'] is Map<String, dynamic>
      ? json['data'] as Map<String, dynamic>
      : json;
  final counts = inner['counts'] is Map<String, dynamic>
      ? inner['counts'] as Map<String, dynamic>
      : inner;
  final stats = inner['stats'] is Map<String, dynamic>
      ? inner['stats'] as Map<String, dynamic>
      : counts;
  return SocialProfile(
    id: _str(inner, ['id', '_id', 'uid']) ?? '',
    handle: _str(inner, ['handle', 'username']) ?? '',
    displayName: _str(inner, ['displayName', 'name', 'firstName']) ?? '',
    avatarUrl: _str(inner, ['avatarUrl', 'avatar', 'photoUrl']),
    bio: _str(inner, ['bio']),
    isPro: inner['isPro'] == true || inner['pro'] == true,
    isFollowing: inner['isFollowing'] == true || inner['following'] == true,
    isMe: inner['isMe'] == true || inner['isSelf'] == true,
    rating: (_num(stats, ['rating', 'avgRating']) ?? 0).toDouble(),
    reviewCount: _int(stats, ['reviewCount', 'reviews', 'ratingCount']),
    followers: _int(stats, ['followers', 'followersCount']),
    following: _int(stats, ['following', 'followingCount']),
    listingsCount: _int(stats, ['listings', 'listingsCount', 'products']),
    location: _str(inner, ['location']),
  );
}

FollowUser mapFollowUser(Object? raw) {
  final json = _obj(raw);
  return FollowUser(
    id: _str(json, ['id', '_id', 'uid']) ?? '',
    displayName: _str(json, ['displayName', 'name']) ?? '',
    handle: _str(json, ['handle', 'username']) ?? '',
    avatarUrl: _str(json, ['avatarUrl', 'avatar', 'photoUrl']),
    isPro: json['isPro'] == true || json['pro'] == true,
    isFollowing: json['isFollowing'] == true || json['following'] == true,
  );
}

ProfileReel mapProfileReel(Object? raw) {
  final json = _obj(raw);
  return ProfileReel(
    id: _str(json, ['id', '_id']) ?? '',
    thumbnailUrl: _str(json, [
      'thumbnailUrl',
      'thumbnail',
      'posterUrl',
      'coverUrl',
    ]),
    views: _int(json, ['views', 'viewCount']),
  );
}

UserReview mapUserReview(Object? raw) {
  final json = _obj(raw);
  final author = json['author'] is Map<String, dynamic>
      ? json['author'] as Map<String, dynamic>
      : (json['reviewer'] is Map<String, dynamic>
            ? json['reviewer'] as Map<String, dynamic>
            : json);
  return UserReview(
    id: _str(json, ['id', '_id']) ?? '',
    authorName: _str(author, ['displayName', 'name', 'handle']) ?? '',
    authorAvatar: _str(author, ['avatarUrl', 'avatar']),
    rating: (_num(json, ['rating', 'stars']) ?? 0).toDouble(),
    body: _str(json, ['body', 'text', 'comment']) ?? '',
    createdAt: DateTime.tryParse(_str(json, ['createdAt', 'created']) ?? ''),
  );
}

Map<String, dynamic> _obj(Object? raw) =>
    raw is Map<String, dynamic> ? raw : const <String, dynamic>{};

String? _str(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.isNotEmpty) return value;
  }
  return null;
}

num? _num(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is num) return value;
    if (value is String) {
      final parsed = num.tryParse(value);
      if (parsed != null) return parsed;
    }
  }
  return null;
}

int _int(Map<String, dynamic> json, List<String> keys) =>
    (_num(json, keys) ?? 0).toInt();
