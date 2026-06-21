import 'package:equatable/equatable.dart';

/// A user profile (self or public) for the profile screen.
class SocialProfile extends Equatable {
  final String id;

  /// Firebase UID — the id the chat feature keys conversations by (ChatEntry).
  final String firebaseUid;
  final String displayName;
  final String? avatarUrl;
  final String? bio;
  final bool isPro;
  final bool isFollowing;
  final bool isMe;
  final double rating;
  final int reviewCount;
  final int followers;
  final int following;
  final int listingsCount;
  final String? location;

  const SocialProfile({
    required this.id,
    this.firebaseUid = '',
    this.displayName = '',
    this.avatarUrl,
    this.bio,
    this.isPro = false,
    this.isFollowing = false,
    this.isMe = false,
    this.rating = 0,
    this.reviewCount = 0,
    this.followers = 0,
    this.following = 0,
    this.listingsCount = 0,
    this.location,
  });

  String get name => displayName;

  SocialProfile copyWith({bool? isFollowing, int? followers}) {
    return SocialProfile(
      id: id,
      firebaseUid: firebaseUid,
      displayName: displayName,
      avatarUrl: avatarUrl,
      bio: bio,
      isPro: isPro,
      isFollowing: isFollowing ?? this.isFollowing,
      isMe: isMe,
      rating: rating,
      reviewCount: reviewCount,
      followers: followers ?? this.followers,
      following: following,
      listingsCount: listingsCount,
      location: location,
    );
  }

  @override
  List<Object?> get props => [
    id,
    firebaseUid,
    displayName,
    avatarUrl,
    bio,
    isPro,
    isFollowing,
    isMe,
    rating,
    reviewCount,
    followers,
    following,
    listingsCount,
    location,
  ];
}
