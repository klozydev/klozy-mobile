import 'package:equatable/equatable.dart';

/// A reel thumbnail in the profile Reels grid.
class ProfileReel extends Equatable {
  final String id;
  final String? thumbnailUrl;
  final int views;

  const ProfileReel({required this.id, this.thumbnailUrl, this.views = 0});

  @override
  List<Object?> get props => [id, thumbnailUrl, views];
}
