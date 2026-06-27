import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/chat/domain/chat_repository.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_thread.dart';
import 'package:klozy/src/feature/chat/domain/usecase/watch_thread.dart';
import 'package:mocktail/mocktail.dart';

class _MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late _MockChatRepository mockRepo;
  late WatchThread useCase;

  setUp(() {
    mockRepo = _MockChatRepository();
    useCase = WatchThread(mockRepo);
  });

  group('WatchThread', () {
    test('returns the stream from the repository for given threadId', () {
      const ChatThread thread = ChatThread(id: 'thread-1');
      final Stream<ChatThread?> stream = Stream<ChatThread?>.value(thread);

      when(() => mockRepo.watchThread('thread-1')).thenAnswer((_) => stream);

      final Stream<ChatThread?> result = useCase('thread-1');

      verify(() => mockRepo.watchThread('thread-1')).called(1);
      expect(result, emits(thread));
    });

    test('passes the threadId argument correctly', () {
      when(
        () => mockRepo.watchThread(any()),
      ).thenAnswer((_) => const Stream<ChatThread?>.empty());

      useCase('thread-abc');

      verify(() => mockRepo.watchThread('thread-abc')).called(1);
    });
  });
}
