/// Kind of a chat media asset, mirroring the Firestore `mediaType` strings
/// (`image` / `video` / `audio` / `other`) written by the legacy chat.
enum MediaType {
  image,
  video,
  audio,
  other;

  /// Parses the raw Firestore string; unknown / null falls back to [other].
  static MediaType fromRaw(String? raw) {
    switch (raw) {
      case 'image':
        return MediaType.image;
      case 'video':
        return MediaType.video;
      case 'audio':
        return MediaType.audio;
      default:
        return MediaType.other;
    }
  }

  String get raw => name;
}
