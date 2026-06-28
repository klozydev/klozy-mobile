import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/chat/data/response/chat_reply_response.dart';

void main() {
  // ── fromJson ────────────────────────────────────────────────────────────────

  group('ChatReplyResponse.fromJson', () {
    test('parses all fields', () {
      final ChatReplyResponse r = ChatReplyResponse.fromJson(<String, dynamic>{
        'id': 'msg-orig',
        'senderId': 'uid-other',
        'type': 'text',
        'text': 'Original text',
      });

      expect(r.id, 'msg-orig');
      expect(r.senderId, 'uid-other');
      expect(r.type, 'text');
      expect(r.text, 'Original text');
    });

    test('parses all fields as null when absent', () {
      final ChatReplyResponse r = ChatReplyResponse.fromJson(
        <String, dynamic>{},
      );

      expect(r.id, isNull);
      expect(r.senderId, isNull);
      expect(r.type, isNull);
      expect(r.text, isNull);
    });

    test('parses media reply type', () {
      final ChatReplyResponse r = ChatReplyResponse.fromJson(<String, dynamic>{
        'id': 'msg-2',
        'type': 'media',
      });

      expect(r.type, 'media');
      expect(r.text, isNull);
    });
  });

  // ── toJson ──────────────────────────────────────────────────────────────────

  group('ChatReplyResponse.toJson', () {
    test('serialises all fields', () {
      const ChatReplyResponse r = ChatReplyResponse(
        id: 'msg-3',
        senderId: 'uid-me',
        type: 'offer',
        text: null,
      );

      final Map<String, dynamic> json = r.toJson();

      expect(json['id'], 'msg-3');
      expect(json['senderId'], 'uid-me');
      expect(json['type'], 'offer');
      expect(json['text'], isNull);
    });

    test('serialises null fields as null', () {
      const ChatReplyResponse r = ChatReplyResponse();

      final Map<String, dynamic> json = r.toJson();

      expect(json['id'], isNull);
      expect(json['senderId'], isNull);
      expect(json['type'], isNull);
      expect(json['text'], isNull);
    });
  });

  // ── round-trip ──────────────────────────────────────────────────────────────

  group('ChatReplyResponse round-trip', () {
    test('fromJson → toJson is identity for all fields', () {
      final Map<String, dynamic> input = <String, dynamic>{
        'id': 'msg-rt',
        'senderId': 'uid-sender',
        'type': 'text',
        'text': 'Reply to this',
      };

      final Map<String, dynamic> output = ChatReplyResponse.fromJson(
        input,
      ).toJson();

      expect(output, input);
    });

    test('fromJson → toJson is identity for all-null', () {
      final Map<String, dynamic> input = <String, dynamic>{
        'id': null,
        'senderId': null,
        'type': null,
        'text': null,
      };

      final Map<String, dynamic> output = ChatReplyResponse.fromJson(
        input,
      ).toJson();

      expect(output, input);
    });
  });
}
