import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/chat/domain/chat_repository.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_message.dart';
import 'package:klozy/src/feature/chat/domain/entity/message_kind.dart';
import 'package:klozy/src/feature/chat/domain/usecase/watch_messages.dart';
import 'package:mocktail/mocktail.dart';

class _MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late _MockChatRepository mockRepo;
  late WatchMessages useCase;

  setUp(() {
    mockRepo = _MockChatRepository();
    useCase = WatchMessages(mockRepo);
  });

  group('WatchMessages', () {
    test('returns the messages stream from the repository', () {
      const ChatMessage message = ChatMessage(
        id: 'msg-1',
        threadId: 'thread-1',
        senderId: 'u1',
        kind: ChatMessageKind.text,
        isMine: true,
      );
      final Stream<List<ChatMessage>> stream = Stream<List<ChatMessage>>.value(
        <ChatMessage>[message],
      );

      when(() => mockRepo.watchMessages('thread-1')).thenAnswer((_) => stream);

      final Stream<List<ChatMessage>> result = useCase('thread-1');

      verify(() => mockRepo.watchMessages('thread-1')).called(1);
      expect(result, emits(<ChatMessage>[message]));
    });

    test('passes the threadId argument correctly', () {
      when(
        () => mockRepo.watchMessages(any()),
      ).thenAnswer((_) => const Stream<List<ChatMessage>>.empty());

      useCase('thread-xyz');

      verify(() => mockRepo.watchMessages('thread-xyz')).called(1);
    });
  });
}
