import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/chat/domain/chat_repository.dart';
import 'package:klozy/src/feature/chat/domain/usecase/open_or_create_thread.dart';
import 'package:mocktail/mocktail.dart';

class _MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late _MockChatRepository mockRepo;
  late OpenOrCreateThread useCase;

  setUp(() {
    mockRepo = _MockChatRepository();
    useCase = OpenOrCreateThread(mockRepo);
  });

  group('OpenOrCreateThread', () {
    test('returns thread id from repo when thread exists', () async {
      when(
        () => mockRepo.openOrCreateThread(
          'user-2',
          displayName: 'Bob',
          avatarUrl: 'https://example.com/bob.jpg',
        ),
      ).thenAnswer((_) async => 'thread-1');

      final String? result = await useCase(
        'user-2',
        displayName: 'Bob',
        avatarUrl: 'https://example.com/bob.jpg',
      );

      expect(result, 'thread-1');
      verify(
        () => mockRepo.openOrCreateThread(
          'user-2',
          displayName: 'Bob',
          avatarUrl: 'https://example.com/bob.jpg',
        ),
      ).called(1);
    });

    test('returns null when repo returns null', () async {
      when(
        () => mockRepo.openOrCreateThread(
          any(),
          displayName: any(named: 'displayName'),
          avatarUrl: any(named: 'avatarUrl'),
        ),
      ).thenAnswer((_) async => null);

      final String? result = await useCase('user-3');

      expect(result, isNull);
    });

    test('passes optional args as null when not provided', () async {
      when(
        () => mockRepo.openOrCreateThread(
          'user-4',
          displayName: null,
          avatarUrl: null,
        ),
      ).thenAnswer((_) async => 'thread-new');

      await useCase('user-4');

      verify(
        () => mockRepo.openOrCreateThread(
          'user-4',
          displayName: null,
          avatarUrl: null,
        ),
      ).called(1);
    });
  });
}
