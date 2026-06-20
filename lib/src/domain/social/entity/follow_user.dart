import 'package:equatable/equatable.dart';

/// A row in a followers/following list.
class FollowUser extends Equatable {
  final String id;
  final String displayName;
  final String? avatarUrl;
  final bool isPro;
  final bool isFollowing;

  const FollowUser({
    required this.id,
    this.displayName = '',
    this.avatarUrl,
    this.isPro = false,
    this.isFollowing = false,
  });

  String get name => displayName;

  FollowUser copyWith({bool? isFollowing}) {
    return FollowUser(
      id: id,
      displayName: displayName,
      avatarUrl: avatarUrl,
      isPro: isPro,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }

  @override
  List<Object?> get props => [id, displayName, avatarUrl, isPro, isFollowing];
}
