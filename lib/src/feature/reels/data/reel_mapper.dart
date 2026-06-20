import 'package:klozy/src/feature/reels/domain/entity/reel.dart';
import 'package:klozy/src/feature/reels/domain/entity/reel_author.dart';
import 'package:klozy/src/feature/reels/domain/entity/reel_comment.dart';

/// Defensive JSON → [Reel] mapping. Field names + the Mux URL shape
/// (`stream.mux.com/{id}.m3u8`) are assumed pending a live `/v1/reels` response.
Reel mapReel(Object? raw) {
  final json = raw is Map<String, dynamic> ? raw : const <String, dynamic>{};
  final playbackId = _str(json, ['muxPlaybackId', 'playbackId']);

  return Reel(
    id: _str(json, ['id', '_id']) ?? '',
    playbackUrl:
        _str(json, ['playbackUrl', 'hlsUrl', 'streamUrl']) ??
        (playbackId == null ? null : 'https://stream.mux.com/$playbackId.m3u8'),
    posterUrl:
        _str(json, ['posterUrl', 'thumbnailUrl', 'poster']) ??
        (playbackId == null
            ? null
            : 'https://image.mux.com/$playbackId/thumbnail.jpg'),
    caption: _str(json, ['caption']) ?? '',
    author: _author(json),
    likes: _int(json, ['likes', 'likeCount', 'likesCount']),
    isLiked: json['isLiked'] == true || json['liked'] == true,
    viewCount: _int(json, ['viewCount', 'views']),
    taggedCount: _taggedCount(json),
  );
}

/// Defensive JSON → [ReelComment] mapping.
ReelComment mapReelComment(Object? raw) {
  final json = raw is Map<String, dynamic> ? raw : const <String, dynamic>{};
  final author = json['author'] is Map<String, dynamic>
      ? json['author'] as Map<String, dynamic>
      : const <String, dynamic>{};
  return ReelComment(
    id: _str(json, ['id', '_id']) ?? '',
    body: _str(json, ['body', 'text', 'comment']) ?? '',
    authorId:
        _str(author, ['id', '_id', 'uid']) ?? _str(json, ['authorId']) ?? '',
    authorName: _str(author, ['displayName', 'name']) ?? '',
    authorAvatar: _str(author, ['avatarUrl', 'avatar', 'photoUrl']),
    createdAt: DateTime.tryParse(_str(json, ['createdAt', 'created']) ?? ''),
  );
}

ReelAuthor _author(Map<String, dynamic> json) {
  final author = json['author'] is Map<String, dynamic>
      ? json['author'] as Map<String, dynamic>
      : const <String, dynamic>{};
  return ReelAuthor(
    id: _str(author, ['id', '_id', 'uid']) ?? '',
    displayName: _str(author, ['displayName', 'name']) ?? '',
    handle: _str(author, ['handle', 'username', 'userName']),
    avatarUrl: _str(author, ['avatarUrl', 'avatar', 'photoUrl']),
    isPro: author['isPro'] == true || author['pro'] == true,
  );
}

int _taggedCount(Map<String, dynamic> json) {
  final tagged = json['taggedProducts'] ?? json['tagged'];
  if (tagged is List) return tagged.length;
  return _int(json, ['taggedCount', 'taggedProductsCount']);
}

String? _str(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.isNotEmpty) return value;
  }
  return null;
}

int _int(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is num) return value.toInt();
  }
  return 0;
}
