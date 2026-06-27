import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/chat/domain/chat_repository.dart';
import 'package:klozy/src/feature/chat/domain/usecase/delete_conversation.dart';
import 'package:mocktail/mocktail.dart';

class _MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late _MockChatRepository mockRepo;
  late DeleteConversation useCase;

  setUp(() {
    mockRepo = _MockChatRepository();
    useCase = DeleteConversation(mockRepo);
  });

  group('DeleteConversation', () {
    test(
      'delegates to repo.deleteConversation with correct threadId',
      () async {
        when(
          () => mockRepo.deleteConversation('thread-1'),
        ).thenAnswer((_) async {});

        await useCase('thread-1');

        verify(() => mockRepo.deleteConversation('thread-1')).called(1);
      },
    );

    test('passes different threadId correctly', () async {
      when(() => mockRepo.deleteConversation(any())).thenAnswer((_) async {});

      await useCase('thread-xyz');

      verify(() => mockRepo.deleteConversation('thread-xyz')).called(1);
    });
  });
}
