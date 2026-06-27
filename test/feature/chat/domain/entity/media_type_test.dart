import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/chat/domain/entity/media_type.dart';

void main() {
  group('MediaType.fromRaw', () {
    test('parses image', () {
      expect(MediaType.fromRaw('image'), MediaType.image);
    });

    test('parses video', () {
      expect(MediaType.fromRaw('video'), MediaType.video);
    });

    test('parses audio', () {
      expect(MediaType.fromRaw('audio'), MediaType.audio);
    });

    test('returns other for unknown string', () {
      expect(MediaType.fromRaw('pdf'), MediaType.other);
      expect(MediaType.fromRaw(''), MediaType.other);
    });

    test('returns other for null', () {
      expect(MediaType.fromRaw(null), MediaType.other);
    });
  });

  group('MediaType.raw', () {
    test('raw returns the enum name', () {
      expect(MediaType.image.raw, 'image');
      expect(MediaType.video.raw, 'video');
      expect(MediaType.audio.raw, 'audio');
      expect(MediaType.other.raw, 'other');
    });
  });
}
