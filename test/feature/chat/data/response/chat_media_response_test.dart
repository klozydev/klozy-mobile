import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/chat/data/response/chat_media_response.dart';

void main() {
  // ── fromJson ────────────────────────────────────────────────────────────────

  group('ChatMediaResponse.fromJson', () {
    test('parses all fields', () {
      final ChatMediaResponse r = ChatMediaResponse.fromJson(<String, dynamic>{
        'id': 'media-1',
        'url': 'https://cdn.example.com/photo.jpg',
        'type': 'image',
        'name': 'photo.jpg',
        'width': 1080.0,
        'height': 720.0,
        'durationMs': 0,
        'thumbnailUrl': 'https://cdn.example.com/thumb.jpg',
        'relativePath': 'chat_media/conv/media-1.jpg',
      });

      expect(r.id, 'media-1');
      expect(r.url, 'https://cdn.example.com/photo.jpg');
      expect(r.type, 'image');
      expect(r.name, 'photo.jpg');
      expect(r.width, 1080.0);
      expect(r.height, 720.0);
      expect(r.durationMs, 0);
      expect(r.thumbnailUrl, 'https://cdn.example.com/thumb.jpg');
      expect(r.relativePath, 'chat_media/conv/media-1.jpg');
    });

    test('parses all fields as null when absent', () {
      final ChatMediaResponse r = ChatMediaResponse.fromJson(
        <String, dynamic>{},
      );

      expect(r.id, isNull);
      expect(r.url, isNull);
      expect(r.type, isNull);
      expect(r.name, isNull);
      expect(r.width, isNull);
      expect(r.height, isNull);
      expect(r.durationMs, isNull);
      expect(r.thumbnailUrl, isNull);
      expect(r.relativePath, isNull);
    });

    test('coerces integer width/height to double', () {
      final ChatMediaResponse r = ChatMediaResponse.fromJson(<String, dynamic>{
        'width': 1920,
        'height': 1080,
      });

      expect(r.width, 1920.0);
      expect(r.height, 1080.0);
    });

    test('parses video type with durationMs', () {
      final ChatMediaResponse r = ChatMediaResponse.fromJson(<String, dynamic>{
        'type': 'video',
        'durationMs': 5000,
      });

      expect(r.type, 'video');
      expect(r.durationMs, 5000);
    });
  });

  // ── toJson ──────────────────────────────────────────────────────────────────

  group('ChatMediaResponse.toJson', () {
    test('serialises all fields', () {
      const ChatMediaResponse r = ChatMediaResponse(
        id: 'media-2',
        url: 'https://cdn.example.com/v.mp4',
        type: 'video',
        name: 'video.mp4',
        width: 1280.0,
        height: 720.0,
        durationMs: 3000,
        thumbnailUrl: 'https://cdn.example.com/thumb-v.jpg',
        relativePath: 'chat_media/conv/media-2.mp4',
      );

      final Map<String, dynamic> json = r.toJson();

      expect(json['id'], 'media-2');
      expect(json['url'], 'https://cdn.example.com/v.mp4');
      expect(json['type'], 'video');
      expect(json['name'], 'video.mp4');
      expect(json['width'], 1280.0);
      expect(json['height'], 720.0);
      expect(json['durationMs'], 3000);
      expect(json['thumbnailUrl'], 'https://cdn.example.com/thumb-v.jpg');
      expect(json['relativePath'], 'chat_media/conv/media-2.mp4');
    });

    test('serialises null fields as null', () {
      const ChatMediaResponse r = ChatMediaResponse();

      final Map<String, dynamic> json = r.toJson();

      expect(json['id'], isNull);
      expect(json['url'], isNull);
      expect(json['type'], isNull);
      expect(json['name'], isNull);
      expect(json['width'], isNull);
      expect(json['height'], isNull);
      expect(json['durationMs'], isNull);
      expect(json['thumbnailUrl'], isNull);
      expect(json['relativePath'], isNull);
    });
  });

  // ── round-trip ──────────────────────────────────────────────────────────────

  group('ChatMediaResponse round-trip', () {
    test('fromJson → toJson is identity for all fields', () {
      final Map<String, dynamic> input = <String, dynamic>{
        'id': 'media-3',
        'url': 'https://cdn.example.com/a.mp3',
        'type': 'audio',
        'name': 'audio.mp3',
        'width': null,
        'height': null,
        'durationMs': 12000,
        'thumbnailUrl': null,
        'relativePath': 'chat_media/conv/media-3.mp3',
      };

      final Map<String, dynamic> output = ChatMediaResponse.fromJson(
        input,
      ).toJson();

      expect(output, input);
    });

    test('fromJson → toJson is identity for all-null', () {
      final Map<String, dynamic> input = <String, dynamic>{
        'id': null,
        'url': null,
        'type': null,
        'name': null,
        'width': null,
        'height': null,
        'durationMs': null,
        'thumbnailUrl': null,
        'relativePath': null,
      };

      final Map<String, dynamic> output = ChatMediaResponse.fromJson(
        input,
      ).toJson();

      expect(output, input);
    });
  });
}
