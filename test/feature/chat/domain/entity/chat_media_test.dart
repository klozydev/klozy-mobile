import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_media.dart';
import 'package:klozy/src/feature/chat/domain/entity/media_type.dart';

void main() {
  group('ChatMedia', () {
    const ChatMedia media = ChatMedia(
      id: 'm1',
      url: 'https://example.com/img.jpg',
      localPath: '/tmp/img.jpg',
      relativePath: 'images/img.jpg',
      type: MediaType.image,
      name: 'img.jpg',
      width: 1080,
      height: 720,
      durationMs: null,
      thumbnailUrl: 'https://example.com/thumb.jpg',
      thumbnailRelativePath: 'thumbs/img.jpg',
    );

    test('getters return constructor values', () {
      expect(media.id, 'm1');
      expect(media.url, 'https://example.com/img.jpg');
      expect(media.localPath, '/tmp/img.jpg');
      expect(media.relativePath, 'images/img.jpg');
      expect(media.type, MediaType.image);
      expect(media.name, 'img.jpg');
      expect(media.width, 1080);
      expect(media.height, 720);
      expect(media.durationMs, isNull);
      expect(media.thumbnailUrl, 'https://example.com/thumb.jpg');
      expect(media.thumbnailRelativePath, 'thumbs/img.jpg');
    });

    test('defaults to MediaType.other and all nulls', () {
      const ChatMedia empty = ChatMedia();
      expect(empty.id, isNull);
      expect(empty.url, isNull);
      expect(empty.localPath, isNull);
      expect(empty.relativePath, isNull);
      expect(empty.type, MediaType.other);
      expect(empty.name, isNull);
      expect(empty.width, isNull);
      expect(empty.height, isNull);
      expect(empty.durationMs, isNull);
      expect(empty.thumbnailUrl, isNull);
      expect(empty.thumbnailRelativePath, isNull);
    });

    test('two instances with same fields are equal', () {
      const ChatMedia other = ChatMedia(
        id: 'm1',
        url: 'https://example.com/img.jpg',
        localPath: '/tmp/img.jpg',
        relativePath: 'images/img.jpg',
        type: MediaType.image,
        name: 'img.jpg',
        width: 1080,
        height: 720,
        thumbnailUrl: 'https://example.com/thumb.jpg',
        thumbnailRelativePath: 'thumbs/img.jpg',
      );
      expect(media, equals(other));
      expect(media.hashCode, equals(other.hashCode));
    });

    test('instances with different url are not equal', () {
      const ChatMedia other = ChatMedia(
        id: 'm1',
        url: 'https://example.com/other.jpg',
        type: MediaType.image,
      );
      expect(media, isNot(equals(other)));
    });
  });
}
