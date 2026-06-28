import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/chat/domain/chat_repository.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_thread.dart';
import 'package:klozy/src/feature/chat/domain/usecase/watch_threads.dart';
import 'package:mocktail/mocktail.dart';

class _MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late _MockChatRepository mockRepo;
  late WatchThreads useCase;

  setUp(() {
    mockRepo = _MockChatRepository();
    useCase = WatchThreads(mockRepo);
  });

  group('WatchThreads', () {
    test('returns the stream from the repository', () {
      const ChatThread thread = ChatThread(id: 'thread-1');
      final Stream<List<ChatThread>> stream = Stream<List<ChatThread>>.value(
        <ChatThread>[thread],
      );

      when(() => mockRepo.watchThreads()).thenAnswer((_) => stream);

      final Stream<List<ChatThread>> result = useCase();

      verify(() => mockRepo.watchThreads()).called(1);
      expect(result, emits(<ChatThread>[thread]));
    });
  });
}
