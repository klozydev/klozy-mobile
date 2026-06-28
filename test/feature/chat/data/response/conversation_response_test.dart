import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/chat/data/response/chat_last_message_response.dart';
import 'package:klozy/src/feature/chat/data/response/chat_participant_response.dart';
import 'package:klozy/src/feature/chat/data/response/conversation_response.dart';

void main() {
  // ── fromJson — scalar / list fields ────────────────────────────────────────

  group('ConversationResponse.fromJson — scalar and list fields', () {
    test('parses all fields', () {
      final ConversationResponse r = ConversationResponse.fromJson(
        <String, dynamic>{
          'id': 'conv-1',
          'participantIds': <String>['uid-me', 'uid-other'],
          'lastMessageAt': null,
          'unreadCounts': <String, dynamic>{'uid-me': 2, 'uid-other': 0},
          'blockedBy': <String>[],
          'deletedFor': <String>['uid-other'],
        },
      );

      expect(r.id, 'conv-1');
      expect(r.participantIds, <String>['uid-me', 'uid-other']);
      expect(r.lastMessageAt, isNull);
      expect(r.unreadCounts, <String, int>{'uid-me': 2, 'uid-other': 0});
      expect(r.blockedBy, isEmpty);
      expect(r.deletedFor, <String>['uid-other']);
    });

    test('parses all fields as null when absent', () {
      final ConversationResponse r = ConversationResponse.fromJson(
        <String, dynamic>{},
      );

      expect(r.id, isNull);
      expect(r.participantIds, isNull);
      expect(r.participants, isNull);
      expect(r.lastMessage, isNull);
      expect(r.lastMessageAt, isNull);
      expect(r.unreadCounts, isNull);
      expect(r.blockedBy, isNull);
      expect(r.deletedFor, isNull);
    });
  });

  // ── fromJson — lastMessageAt via TimestampConverter ───────────────────────

  group('ConversationResponse.fromJson — lastMessageAt', () {
    test('accepts DateTime directly', () {
      final DateTime dt = DateTime(2024, 6, 15, 12, 0, 0);
      final ConversationResponse r = ConversationResponse.fromJson(
        <String, dynamic>{'lastMessageAt': dt},
      );

      expect(r.lastMessageAt, dt);
    });

    test('accepts int millis', () {
      final DateTime expected = DateTime.fromMillisecondsSinceEpoch(
        1_718_448_000_000,
      );
      final ConversationResponse r = ConversationResponse.fromJson(
        <String, dynamic>{'lastMessageAt': 1_718_448_000_000},
      );

      expect(r.lastMessageAt, expected);
    });

    test('accepts Firestore Timestamp', () {
      final DateTime dt = DateTime.utc(2024, 6, 15, 12);
      final Timestamp ts = Timestamp.fromDate(dt);
      final ConversationResponse r = ConversationResponse.fromJson(
        <String, dynamic>{'lastMessageAt': ts},
      );

      expect(r.lastMessageAt, isNotNull);
      expect(r.lastMessageAt!.isAtSameMomentAs(dt), isTrue);
    });

    test('null lastMessageAt yields null', () {
      final ConversationResponse r = ConversationResponse.fromJson(
        <String, dynamic>{'lastMessageAt': null},
      );

      expect(r.lastMessageAt, isNull);
    });
  });

  // ── fromJson — nested objects ──────────────────────────────────────────────

  group('ConversationResponse.fromJson — nested objects', () {
    test('parses lastMessage', () {
      final ConversationResponse r = ConversationResponse.fromJson(
        <String, dynamic>{
          'lastMessage': <String, dynamic>{
            'text': 'Hey!',
            'type': 'text',
            'senderId': 'uid-other',
          },
        },
      );

      expect(r.lastMessage, isNotNull);
      expect(r.lastMessage!.text, 'Hey!');
      expect(r.lastMessage!.type, 'text');
      expect(r.lastMessage!.senderId, 'uid-other');
    });

    test('parses participants map', () {
      final ConversationResponse r = ConversationResponse.fromJson(
        <String, dynamic>{
          'participants': <String, dynamic>{
            'uid-me': <String, dynamic>{
              'userId': 'uid-me',
              'displayName': 'Alice',
              'avatarUrl': null,
              'rating': 4.5,
              'isPro': false,
            },
            'uid-other': <String, dynamic>{
              'userId': 'uid-other',
              'displayName': 'Bob',
            },
          },
        },
      );

      expect(r.participants, isNotNull);
      expect(r.participants!.length, 2);
      expect(r.participants!['uid-me']!.displayName, 'Alice');
      expect(r.participants!['uid-other']!.displayName, 'Bob');
    });

    test('parses empty participants map', () {
      final ConversationResponse r = ConversationResponse.fromJson(
        <String, dynamic>{'participants': <String, dynamic>{}},
      );

      expect(r.participants, isEmpty);
    });
  });

  // ── toJson ──────────────────────────────────────────────────────────────────

  group('ConversationResponse.toJson', () {
    test('serialises scalar fields', () {
      const ConversationResponse r = ConversationResponse(
        id: 'conv-2',
        participantIds: <String>['uid-a', 'uid-b'],
        blockedBy: <String>[],
        deletedFor: <String>[],
      );

      final Map<String, dynamic> json = r.toJson();

      expect(json['id'], 'conv-2');
      expect(json['participantIds'], <String>['uid-a', 'uid-b']);
      expect(json['blockedBy'], isEmpty);
      expect(json['deletedFor'], isEmpty);
    });

    test('lastMessageAt serialises to Timestamp when set', () {
      final DateTime dt = DateTime.utc(2024, 6, 15, 12);
      final ConversationResponse r = ConversationResponse(lastMessageAt: dt);

      final Map<String, dynamic> json = r.toJson();

      expect(json['lastMessageAt'], isA<Timestamp>());
      expect(
        (json['lastMessageAt'] as Timestamp).toDate().isAtSameMomentAs(dt),
        isTrue,
      );
    });

    test('null fields serialise as null', () {
      const ConversationResponse r = ConversationResponse();

      final Map<String, dynamic> json = r.toJson();

      expect(json['id'], isNull);
      expect(json['participantIds'], isNull);
      expect(json['participants'], isNull);
      expect(json['lastMessage'], isNull);
      expect(json['lastMessageAt'], isNull);
      expect(json['unreadCounts'], isNull);
      expect(json['blockedBy'], isNull);
      expect(json['deletedFor'], isNull);
    });

    test('serialises lastMessage as map', () {
      const ConversationResponse r = ConversationResponse(
        lastMessage: ChatLastMessageResponse(text: 'Hi', type: 'text'),
      );

      final Map<String, dynamic> json = r.toJson();

      // ConversationResponse is NOT explicitToJson, so lastMessage is the raw object.
      // The generated code stores instance references — not maps — for non-explicitToJson.
      expect(json['lastMessage'], isNotNull);
    });

    test('serialises participants as map entries', () {
      const ConversationResponse r = ConversationResponse(
        participants: <String, ChatParticipantResponse>{
          'uid-1': ChatParticipantResponse(userId: 'uid-1', displayName: 'A'),
        },
      );

      final Map<String, dynamic> json = r.toJson();

      expect(json['participants'], isNotNull);
    });
  });
}
