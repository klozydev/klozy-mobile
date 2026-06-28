import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/chat/domain/chat_repository.dart';
import 'package:klozy/src/feature/chat/domain/usecase/mark_thread_seen.dart';
import 'package:mocktail/mocktail.dart';

class _MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late _MockChatRepository mockRepo;
  late MarkThreadSeen useCase;

  setUp(() {
    mockRepo = _MockChatRepository();
    useCase = MarkThreadSeen(mockRepo);
  });

  group('MarkThreadSeen', () {
    test('delegates to repo.markSeen with correct threadId', () async {
      when(() => mockRepo.markSeen('thread-1')).thenAnswer((_) async {});

      await useCase('thread-1');

      verify(() => mockRepo.markSeen('thread-1')).called(1);
    });

    test('passes different threadId correctly', () async {
      when(() => mockRepo.markSeen(any())).thenAnswer((_) async {});

      await useCase('thread-abc');

      verify(() => mockRepo.markSeen('thread-abc')).called(1);
    });
  });
}
