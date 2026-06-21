import 'package:equatable/equatable.dart';
import 'package:klozy/src/feature/chat/domain/entity/media_type.dart';

/// A single media asset attached to a chat message (image, video, audio file).
///
/// Field shapes mirror the legacy `MediaModel` Firestore document so existing
/// threads keep rendering: `mediaUrl`, `mediaRelativePath`, `mediaType`,
/// `videoThumbnail`, etc.
class ChatMedia extends Equatable {
  final String? id;
  final String? url;

  /// Local file path for an optimistic (not-yet-uploaded) outgoing asset.
  final String? localPath;
  final String? relativePath;
  final MediaType type;
  final String? name;
  final double? width;
  final double? height;

  /// Duration in milliseconds (audio / video).
  final int? durationMs;
  final String? thumbnailUrl;
  final String? thumbnailRelativePath;

  const ChatMedia({
    this.id,
    this.url,
    this.localPath,
    this.relativePath,
    this.type = MediaType.other,
    this.name,
    this.width,
    this.height,
    this.durationMs,
    this.thumbnailUrl,
    this.thumbnailRelativePath,
  });

  @override
  List<Object?> get props => <Object?>[
    id,
    url,
    localPath,
    relativePath,
    type,
    name,
    width,
    height,
    durationMs,
    thumbnailUrl,
    thumbnailRelativePath,
  ];
}
