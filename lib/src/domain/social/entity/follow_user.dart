import 'package:equatable/equatable.dart';

/// A row in a followers/following list.
class FollowUser extends Equatable {
  final String id;
  final String displayName;
  final String handle;
  final String? avatarUrl;
  final bool isPro;
  final bool isFollowing;

  const FollowUser({
    required this.id,
    this.displayName = '',
    this.handle = '',
    this.avatarUrl,
    this.isPro = false,
    this.isFollowing = false,
  });

  String get name => displayName.isEmpty ? '@$handle' : displayName;

  FollowUser copyWith({bool? isFollowing}) {
    return FollowUser(
      id: id,
      displayName: displayName,
      handle: handle,
      avatarUrl: avatarUrl,
      isPro: isPro,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }

  @override
  List<Object?> get props => [
    id,
    displayName,
    handle,
    avatarUrl,
    isPro,
    isFollowing,
  ];
}
