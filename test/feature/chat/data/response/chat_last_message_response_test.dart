import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/chat/data/response/chat_last_message_response.dart';

void main() {
  // ── fromJson ────────────────────────────────────────────────────────────────

  group('ChatLastMessageResponse.fromJson', () {
    test('parses all fields', () {
      final ChatLastMessageResponse r = ChatLastMessageResponse.fromJson(
        <String, dynamic>{
          'text': 'Hey!',
          'type': 'text',
          'senderId': 'uid-sender',
        },
      );

      expect(r.text, 'Hey!');
      expect(r.type, 'text');
      expect(r.senderId, 'uid-sender');
    });

    test('parses all fields as null when absent', () {
      final ChatLastMessageResponse r = ChatLastMessageResponse.fromJson(
        <String, dynamic>{},
      );

      expect(r.text, isNull);
      expect(r.type, isNull);
      expect(r.senderId, isNull);
    });

    test('parses non-text type', () {
      final ChatLastMessageResponse r = ChatLastMessageResponse.fromJson(
        <String, dynamic>{'type': 'media', 'senderId': 'uid-1'},
      );

      expect(r.text, isNull);
      expect(r.type, 'media');
      expect(r.senderId, 'uid-1');
    });
  });

  // ── toJson ──────────────────────────────────────────────────────────────────

  group('ChatLastMessageResponse.toJson', () {
    test('serialises all fields', () {
      const ChatLastMessageResponse r = ChatLastMessageResponse(
        text: 'Hello',
        type: 'text',
        senderId: 'uid-me',
      );

      final Map<String, dynamic> json = r.toJson();

      expect(json['text'], 'Hello');
      expect(json['type'], 'text');
      expect(json['senderId'], 'uid-me');
    });

    test('serialises null fields as null', () {
      const ChatLastMessageResponse r = ChatLastMessageResponse();

      final Map<String, dynamic> json = r.toJson();

      expect(json['text'], isNull);
      expect(json['type'], isNull);
      expect(json['senderId'], isNull);
    });
  });

  // ── round-trip ──────────────────────────────────────────────────────────────

  group('ChatLastMessageResponse round-trip', () {
    test('fromJson → toJson is identity for all fields present', () {
      final Map<String, dynamic> input = <String, dynamic>{
        'text': 'Bye!',
        'type': 'offer',
        'senderId': 'uid-42',
      };

      final Map<String, dynamic> output = ChatLastMessageResponse.fromJson(
        input,
      ).toJson();

      expect(output, input);
    });

    test('fromJson → toJson is identity for all-null', () {
      final Map<String, dynamic> input = <String, dynamic>{
        'text': null,
        'type': null,
        'senderId': null,
      };

      final Map<String, dynamic> output = ChatLastMessageResponse.fromJson(
        input,
      ).toJson();

      expect(output, input);
    });
  });
}
