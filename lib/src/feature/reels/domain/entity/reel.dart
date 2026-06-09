import 'package:equatable/equatable.dart';
import 'package:klozy/src/feature/reels/domain/entity/reel_author.dart';

class Reel extends Equatable {
  final String id;
  final String? playbackUrl;
  final String? posterUrl;
  final String caption;
  final ReelAuthor author;
  final int likes;
  final bool isLiked;
  final int viewCount;
  final int taggedCount;

  const Reel({
    required this.id,
    required this.author,
    this.playbackUrl,
    this.posterUrl,
    this.caption = '',
    this.likes = 0,
    this.isLiked = false,
    this.viewCount = 0,
    this.taggedCount = 0,
  });

  Reel copyWith({int? likes, bool? isLiked}) {
    return Reel(
      id: id,
      author: author,
      playbackUrl: playbackUrl,
      posterUrl: posterUrl,
      caption: caption,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
      viewCount: viewCount,
      taggedCount: taggedCount,
    );
  }

  @override
  List<Object?> get props => [
    id,
    playbackUrl,
    posterUrl,
    caption,
    author,
    likes,
    isLiked,
    viewCount,
    taggedCount,
  ];
}
