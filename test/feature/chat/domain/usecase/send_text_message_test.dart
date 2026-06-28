import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/chat/domain/chat_repository.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_message.dart';
import 'package:klozy/src/feature/chat/domain/entity/message_kind.dart';
import 'package:klozy/src/feature/chat/domain/usecase/send_text_message.dart';
import 'package:mocktail/mocktail.dart';

class _MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late _MockChatRepository mockRepo;
  late SendTextMessage useCase;

  setUpAll(() {
    registerFallbackValue(
      const ChatMessage(
        id: '',
        threadId: '',
        senderId: '',
        kind: ChatMessageKind.text,
        isMine: false,
      ),
    );
  });

  setUp(() {
    mockRepo = _MockChatRepository();
    useCase = SendTextMessage(mockRepo);
  });

  group('SendTextMessage', () {
    test('delegates to repo.sendText with correct args', () async {
      when(
        () => mockRepo.sendText(
          'thread-1',
          'Hello!',
          clientId: 'cid-1',
          replyTo: null,
        ),
      ).thenAnswer((_) async {});

      await useCase('thread-1', 'Hello!', clientId: 'cid-1');

      verify(
        () => mockRepo.sendText(
          'thread-1',
          'Hello!',
          clientId: 'cid-1',
          replyTo: null,
        ),
      ).called(1);
    });

    test('passes replyTo message to the repo', () async {
      const ChatMessage reply = ChatMessage(
        id: 'msg-0',
        threadId: 'thread-1',
        senderId: 'u2',
        kind: ChatMessageKind.text,
        isMine: false,
      );

      when(
        () => mockRepo.sendText(
          any(),
          any(),
          clientId: any(named: 'clientId'),
          replyTo: any(named: 'replyTo'),
        ),
      ).thenAnswer((_) async {});

      await useCase('thread-1', 'Reply!', clientId: 'cid-2', replyTo: reply);

      verify(
        () => mockRepo.sendText(
          'thread-1',
          'Reply!',
          clientId: 'cid-2',
          replyTo: reply,
        ),
      ).called(1);
    });
  });
}
