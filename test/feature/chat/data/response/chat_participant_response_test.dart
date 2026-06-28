import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/chat/data/response/chat_participant_response.dart';

void main() {
  // ── fromJson ────────────────────────────────────────────────────────────────

  group('ChatParticipantResponse.fromJson', () {
    test('parses all fields', () {
      final ChatParticipantResponse r =
          ChatParticipantResponse.fromJson(<String, dynamic>{
            'userId': 'uid-1',
            'displayName': 'Alice',
            'avatarUrl': 'https://cdn.example.com/avatar.jpg',
            'rating': 4.5,
            'isPro': true,
          });

      expect(r.userId, 'uid-1');
      expect(r.displayName, 'Alice');
      expect(r.avatarUrl, 'https://cdn.example.com/avatar.jpg');
      expect(r.rating, 4.5);
      expect(r.isPro, isTrue);
    });

    test('parses all fields as null when absent', () {
      final ChatParticipantResponse r = ChatParticipantResponse.fromJson(
        <String, dynamic>{},
      );

      expect(r.userId, isNull);
      expect(r.displayName, isNull);
      expect(r.avatarUrl, isNull);
      expect(r.rating, isNull);
      expect(r.isPro, isNull);
    });

    test('parses integer rating', () {
      final ChatParticipantResponse r = ChatParticipantResponse.fromJson(
        <String, dynamic>{'rating': 5},
      );

      expect(r.rating, 5);
    });

    test('parses isPro false', () {
      final ChatParticipantResponse r = ChatParticipantResponse.fromJson(
        <String, dynamic>{'isPro': false},
      );

      expect(r.isPro, isFalse);
    });
  });

  // ── toJson ──────────────────────────────────────────────────────────────────

  group('ChatParticipantResponse.toJson', () {
    test('serialises all fields', () {
      const ChatParticipantResponse r = ChatParticipantResponse(
        userId: 'uid-2',
        displayName: 'Bob',
        avatarUrl: 'https://cdn.example.com/bob.jpg',
        rating: 3.0,
        isPro: false,
      );

      final Map<String, dynamic> json = r.toJson();

      expect(json['userId'], 'uid-2');
      expect(json['displayName'], 'Bob');
      expect(json['avatarUrl'], 'https://cdn.example.com/bob.jpg');
      expect(json['rating'], 3.0);
      expect(json['isPro'], isFalse);
    });

    test('serialises null fields as null', () {
      const ChatParticipantResponse r = ChatParticipantResponse();

      final Map<String, dynamic> json = r.toJson();

      expect(json['userId'], isNull);
      expect(json['displayName'], isNull);
      expect(json['avatarUrl'], isNull);
      expect(json['rating'], isNull);
      expect(json['isPro'], isNull);
    });
  });

  // ── round-trip ──────────────────────────────────────────────────────────────

  group('ChatParticipantResponse round-trip', () {
    test('fromJson → toJson is identity for all fields', () {
      final Map<String, dynamic> input = <String, dynamic>{
        'userId': 'uid-rt',
        'displayName': 'Carol',
        'avatarUrl': 'https://cdn.example.com/carol.jpg',
        'rating': 4.8,
        'isPro': true,
      };

      final Map<String, dynamic> output = ChatParticipantResponse.fromJson(
        input,
      ).toJson();

      expect(output, input);
    });

    test('fromJson → toJson is identity for all-null', () {
      final Map<String, dynamic> input = <String, dynamic>{
        'userId': null,
        'displayName': null,
        'avatarUrl': null,
        'rating': null,
        'isPro': null,
      };

      final Map<String, dynamic> output = ChatParticipantResponse.fromJson(
        input,
      ).toJson();

      expect(output, input);
    });
  });
}
