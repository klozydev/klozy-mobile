import 'dart:io';

import 'package:klozy/src/feature/chat/domain/entity/media_type.dart';

/// A local file the user picked to send, before upload. Built in the widget
/// layer (pickers) and passed to the BLoC via an event.
class ChatOutgoingMedia {
  final File file;
  final MediaType type;
  final String? name;
  final int? durationMs;

  const ChatOutgoingMedia({
    required this.file,
    required this.type,
    this.name,
    this.durationMs,
  });
}
