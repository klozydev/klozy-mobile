import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_outgoing_media.dart';
import 'package:klozy/src/feature/chat/domain/entity/media_type.dart';

void main() {
  group('ChatOutgoingMedia', () {
    test('getters return constructor values', () {
      final File file = File('/tmp/test_audio.m4a');
      const int durationMs = 3000;

      final ChatOutgoingMedia media = ChatOutgoingMedia(
        file: file,
        type: MediaType.audio,
        name: 'test_audio.m4a',
        durationMs: durationMs,
      );

      expect(media.file.path, '/tmp/test_audio.m4a');
      expect(media.type, MediaType.audio);
      expect(media.name, 'test_audio.m4a');
      expect(media.durationMs, 3000);
    });

    test('optional fields default to null', () {
      final File file = File('/tmp/photo.jpg');

      final ChatOutgoingMedia media = ChatOutgoingMedia(
        file: file,
        type: MediaType.image,
      );

      expect(media.name, isNull);
      expect(media.durationMs, isNull);
    });
  });
}
