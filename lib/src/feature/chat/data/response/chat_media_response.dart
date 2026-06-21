import 'package:json_annotation/json_annotation.dart';

part 'chat_media_response.g.dart';

/// A media asset embedded in a message doc (`conversations/{id}/messages`).
@JsonSerializable()
class ChatMediaResponse {
  final String? id;
  final String? url;
  final String? type;
  final String? name;
  final double? width;
  final double? height;
  final int? durationMs;
  final String? thumbnailUrl;
  final String? relativePath;

  const ChatMediaResponse({
    this.id,
    this.url,
    this.type,
    this.name,
    this.width,
    this.height,
    this.durationMs,
    this.thumbnailUrl,
    this.relativePath,
  });

  factory ChatMediaResponse.fromJson(Map<String, dynamic> json) =>
      _$ChatMediaResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMediaResponseToJson(this);
}
