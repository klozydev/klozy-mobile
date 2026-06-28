import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_participant.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_thread.dart';

void main() {
  const ChatParticipant otherUser = ChatParticipant(
    id: 'u2',
    displayName: 'Bob',
    avatarUrl: 'https://example.com/bob.jpg',
  );

  group('ChatThread', () {
    final DateTime ts = DateTime(2024, 7, 1, 9, 30);

    final ChatThread thread = ChatThread(
      id: 'thread-1',
      participants: const <String>['u1', 'u2'],
      other: otherUser,
      hasLastMessage: true,
      lastMessageType: 'text',
      lastMessageText: 'Hey there!',
      lastMessageFromMe: false,
      lastMessageAt: ts,
      timeLabel: '9:30',
      unreadCount: 3,
      blockedBy: const <String>[],
    );

    test('getters return constructor values', () {
      expect(thread.id, 'thread-1');
      expect(thread.participants, <String>['u1', 'u2']);
      expect(thread.other, otherUser);
      expect(thread.hasLastMessage, isTrue);
      expect(thread.lastMessageType, 'text');
      expect(thread.lastMessageText, 'Hey there!');
      expect(thread.lastMessageFromMe, isFalse);
      expect(thread.lastMessageAt, ts);
      expect(thread.timeLabel, '9:30');
      expect(thread.unreadCount, 3);
      expect(thread.blockedBy, isEmpty);
    });

    test('hasUnread is true when unreadCount > 0', () {
      expect(thread.hasUnread, isTrue);
    });

    test('hasUnread is false when unreadCount is 0', () {
      const ChatThread noUnread = ChatThread(id: 'thread-2');
      expect(noUnread.hasUnread, isFalse);
    });

    test('defaults for optional fields', () {
      const ChatThread minimal = ChatThread(id: 'thread-3');
      expect(minimal.participants, isEmpty);
      expect(minimal.other, ChatParticipant.unknown);
      expect(minimal.hasLastMessage, isFalse);
      expect(minimal.lastMessageType, isNull);
      expect(minimal.lastMessageText, isNull);
      expect(minimal.lastMessageFromMe, isFalse);
      expect(minimal.lastMessageAt, isNull);
      expect(minimal.timeLabel, '');
      expect(minimal.unreadCount, 0);
      expect(minimal.blockedBy, isEmpty);
    });

    test('two instances with same fields are equal', () {
      final ChatThread other = ChatThread(
        id: 'thread-1',
        participants: const <String>['u1', 'u2'],
        other: otherUser,
        hasLastMessage: true,
        lastMessageType: 'text',
        lastMessageText: 'Hey there!',
        lastMessageFromMe: false,
        lastMessageAt: ts,
        timeLabel: '9:30',
        unreadCount: 3,
        blockedBy: const <String>[],
      );
      expect(thread, equals(other));
      expect(thread.hashCode, equals(other.hashCode));
    });

    test('instances with different id are not equal', () {
      const ChatThread other = ChatThread(id: 'thread-X');
      expect(thread, isNot(equals(other)));
    });
  });
}
