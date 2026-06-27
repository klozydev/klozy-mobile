import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/chat/domain/chat_repository.dart';
import 'package:klozy/src/feature/chat/domain/usecase/report_and_block.dart';
import 'package:mocktail/mocktail.dart';

class _MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late _MockChatRepository mockRepo;
  late ReportAndBlock useCase;

  setUp(() {
    mockRepo = _MockChatRepository();
    useCase = ReportAndBlock(mockRepo);
  });

  group('ReportAndBlock', () {
    test('delegates to repo.reportAndBlock with correct args', () async {
      when(
        () => mockRepo.reportAndBlock('thread-1', 'user-2'),
      ).thenAnswer((_) async {});

      await useCase('thread-1', 'user-2');

      verify(() => mockRepo.reportAndBlock('thread-1', 'user-2')).called(1);
    });

    test('passes both arguments correctly', () async {
      when(
        () => mockRepo.reportAndBlock(any(), any()),
      ).thenAnswer((_) async {});

      await useCase('thread-abc', 'user-xyz');

      verify(() => mockRepo.reportAndBlock('thread-abc', 'user-xyz')).called(1);
    });
  });
}
