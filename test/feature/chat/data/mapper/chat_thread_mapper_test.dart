import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/chat/data/mapper/chat_thread_mapper.dart';
import 'package:klozy/src/feature/chat/data/response/chat_last_message_response.dart';
import 'package:klozy/src/feature/chat/data/response/chat_participant_response.dart';
import 'package:klozy/src/feature/chat/data/response/conversation_response.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const String _myUid = 'uid-me';
const String _myBackendId = 'backend-me';
const String _otherUid = 'uid-other';

final DateTime _now = DateTime(2024, 6, 15, 14, 0, 0);

ConversationResponse _baseConversation({
  String? id = 'conv-1',
  List<String>? participantIds,
  Map<String, ChatParticipantResponse>? participants,
  ChatLastMessageResponse? lastMessage,
  DateTime? lastMessageAt,
  Map<String, int>? unreadCounts,
  List<String>? blockedBy,
}) => ConversationResponse(
  id: id,
  participantIds: participantIds ?? <String>[_myUid, _otherUid],
  participants: participants,
  lastMessage: lastMessage,
  lastMessageAt: lastMessageAt,
  unreadCounts: unreadCounts,
  blockedBy: blockedBy,
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // Basic field mapping
  // -------------------------------------------------------------------------

  group('ChatThreadMapper.toEntity — basic fields', () {
    late final dynamic thread;
    setUpAll(() {
      final lastAt = DateTime(2024, 6, 15, 13, 55, 0);
      thread = ChatThreadMapper.toEntity(
        _baseConversation(
          lastMessage: const ChatLastMessageResponse(
            text: 'Hey!',
            type: 'text',
            senderId: _otherUid,
          ),
          lastMessageAt: lastAt,
          unreadCounts: <String, int>{_myUid: 3, _otherUid: 0},
          blockedBy: <String>[],
          participants: <String, ChatParticipantResponse>{
            _otherUid: const ChatParticipantResponse(
              userId: _otherUid,
              displayName: 'Alice',
              avatarUrl: 'https://cdn.example.com/alice.jpg',
              rating: 4.5,
              isPro: true,
            ),
          },
        ),
        myUid: _myUid,
        now: _now,
      );
    });

    test('id', () => expect(thread.id, 'conv-1'));
    test(
      'participants',
      () => expect(thread.participants, <String>[_myUid, _otherUid]),
    );
    test('hasLastMessage true', () => expect(thread.hasLastMessage, isTrue));
    test('lastMessageType', () => expect(thread.lastMessageType, 'text'));
    test('lastMessageText', () => expect(thread.lastMessageText, 'Hey!'));
    test(
      'lastMessageFromMe false (sender is other)',
      () => expect(thread.lastMessageFromMe, isFalse),
    );
    test('lastMessageAt', () => expect(thread.lastMessageAt, isNotNull));
    test('timeLabel not empty', () => expect(thread.timeLabel, isNotEmpty));
    test('unreadCount for myUid', () => expect(thread.unreadCount, 3));
    test('blockedBy empty', () => expect(thread.blockedBy, isEmpty));
    test('other.id', () => expect(thread.other.id, _otherUid));
    test('other.displayName', () => expect(thread.other.displayName, 'Alice'));
    test(
      'other.avatarUrl',
      () => expect(thread.other.avatarUrl, 'https://cdn.example.com/alice.jpg'),
    );
    test(
      'other.rating',
      () => expect(thread.other.rating, closeTo(4.5, 0.001)),
    );
    test('other.isPro', () => expect(thread.other.isPro, isTrue));
  });

  // -------------------------------------------------------------------------
  // lastMessageFromMe
  // -------------------------------------------------------------------------

  group('ChatThreadMapper.toEntity — lastMessageFromMe', () {
    test('true when last message sent by myUid', () {
      final thread = ChatThreadMapper.toEntity(
        _baseConversation(
          lastMessage: const ChatLastMessageResponse(
            senderId: _myUid,
            type: 'text',
          ),
        ),
        myUid: _myUid,
        now: _now,
      );
      expect(thread.lastMessageFromMe, isTrue);
    });

    test('true when last message sent by myBackendId', () {
      final thread = ChatThreadMapper.toEntity(
        _baseConversation(
          lastMessage: const ChatLastMessageResponse(
            senderId: _myBackendId,
            type: 'text',
          ),
        ),
        myUid: _myUid,
        myBackendId: _myBackendId,
        now: _now,
      );
      expect(thread.lastMessageFromMe, isTrue);
    });

    test('false when senderId is null', () {
      final thread = ChatThreadMapper.toEntity(
        _baseConversation(
          lastMessage: const ChatLastMessageResponse(type: 'text'),
        ),
        myUid: _myUid,
        now: _now,
      );
      expect(thread.lastMessageFromMe, isFalse);
    });

    test('false when senderId is empty', () {
      final thread = ChatThreadMapper.toEntity(
        _baseConversation(
          lastMessage: const ChatLastMessageResponse(
            senderId: '',
            type: 'text',
          ),
        ),
        myUid: _myUid,
        now: _now,
      );
      expect(thread.lastMessageFromMe, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // hasLastMessage
  // -------------------------------------------------------------------------

  group('ChatThreadMapper.toEntity — hasLastMessage', () {
    test('false when lastMessage is null', () {
      final thread = ChatThreadMapper.toEntity(
        _baseConversation(),
        myUid: _myUid,
        now: _now,
      );
      expect(thread.hasLastMessage, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // other participant resolution
  // -------------------------------------------------------------------------

  group('ChatThreadMapper.toEntity — other participant', () {
    test('other defaults when participant not in map', () {
      final thread = ChatThreadMapper.toEntity(
        _baseConversation(participants: <String, ChatParticipantResponse>{}),
        myUid: _myUid,
        now: _now,
      );
      expect(thread.other.id, _otherUid);
      expect(thread.other.displayName, isEmpty);
      expect(thread.other.avatarUrl, isNull);
      expect(thread.other.rating, 0);
      expect(thread.other.isPro, isFalse);
    });

    test('other defaults when participants map is null', () {
      final thread = ChatThreadMapper.toEntity(
        _baseConversation(),
        myUid: _myUid,
        now: _now,
      );
      expect(thread.other.id, _otherUid);
    });

    test('other.id is empty string when all participants match myUid', () {
      final thread = ChatThreadMapper.toEntity(
        _baseConversation(participantIds: <String>[_myUid]),
        myUid: _myUid,
        now: _now,
      );
      expect(thread.other.id, isEmpty);
    });

    test('otherId excludes both myUid and myBackendId', () {
      final thread = ChatThreadMapper.toEntity(
        _baseConversation(
          participantIds: <String>[_myBackendId, _otherUid],
          participants: <String, ChatParticipantResponse>{
            _otherUid: const ChatParticipantResponse(displayName: 'Carol'),
          },
        ),
        myUid: _myUid,
        myBackendId: _myBackendId,
        now: _now,
      );
      expect(thread.other.id, _otherUid);
      expect(thread.other.displayName, 'Carol');
    });
  });

  // -------------------------------------------------------------------------
  // Empty avatarUrl treated as null
  // -------------------------------------------------------------------------

  group('ChatThreadMapper.toEntity — empty avatarUrl is null', () {
    test('empty avatarUrl in participant → null on entity', () {
      final thread = ChatThreadMapper.toEntity(
        _baseConversation(
          participants: <String, ChatParticipantResponse>{
            _otherUid: const ChatParticipantResponse(
              displayName: 'Dave',
              avatarUrl: '',
            ),
          },
        ),
        myUid: _myUid,
        now: _now,
      );
      expect(thread.other.avatarUrl, isNull);
    });
  });

  // -------------------------------------------------------------------------
  // unreadCount
  // -------------------------------------------------------------------------

  group('ChatThreadMapper.toEntity — unreadCount', () {
    test('0 when myUid not in unreadCounts', () {
      final thread = ChatThreadMapper.toEntity(
        _baseConversation(unreadCounts: <String, int>{_otherUid: 5}),
        myUid: _myUid,
        now: _now,
      );
      expect(thread.unreadCount, 0);
    });

    test('0 when unreadCounts is null', () {
      final thread = ChatThreadMapper.toEntity(
        _baseConversation(),
        myUid: _myUid,
        now: _now,
      );
      expect(thread.unreadCount, 0);
    });
  });

  // -------------------------------------------------------------------------
  // blockedBy
  // -------------------------------------------------------------------------

  group('ChatThreadMapper.toEntity — blockedBy', () {
    test('blockedBy list forwarded', () {
      final thread = ChatThreadMapper.toEntity(
        _baseConversation(blockedBy: <String>[_myUid]),
        myUid: _myUid,
        now: _now,
      );
      expect(thread.blockedBy, <String>[_myUid]);
    });

    test('empty list when blockedBy is null', () {
      final thread = ChatThreadMapper.toEntity(
        _baseConversation(),
        myUid: _myUid,
        now: _now,
      );
      expect(thread.blockedBy, isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // Null conversation id
  // -------------------------------------------------------------------------

  group('ChatThreadMapper.toEntity — null id', () {
    test('id defaults to empty string when null', () {
      final thread = ChatThreadMapper.toEntity(
        _baseConversation(id: null),
        myUid: _myUid,
        now: _now,
      );
      expect(thread.id, isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // participantIds null
  // -------------------------------------------------------------------------

  group('ChatThreadMapper.toEntity — null participantIds', () {
    test('participants empty when null', () {
      final thread = ChatThreadMapper.toEntity(
        const ConversationResponse(id: 'x'),
        myUid: _myUid,
        now: _now,
      );
      expect(thread.participants, isEmpty);
      expect(thread.other.id, isEmpty);
    });
  });
}
