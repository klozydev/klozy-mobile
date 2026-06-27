import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/chat/domain/chat_repository.dart';
import 'package:klozy/src/feature/chat/domain/usecase/respond_to_offer.dart';
import 'package:mocktail/mocktail.dart';

class _MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late _MockChatRepository mockRepo;
  late RespondToOffer useCase;

  setUp(() {
    mockRepo = _MockChatRepository();
    useCase = RespondToOffer(mockRepo);
  });

  group('RespondToOffer', () {
    test('delegates accept=true to repo.respondToOffer', () async {
      when(
        () => mockRepo.respondToOffer('off-1', accept: true),
      ).thenAnswer((_) async {});

      await useCase('off-1', accept: true);

      verify(() => mockRepo.respondToOffer('off-1', accept: true)).called(1);
    });

    test('delegates accept=false to repo.respondToOffer', () async {
      when(
        () => mockRepo.respondToOffer('off-1', accept: false),
      ).thenAnswer((_) async {});

      await useCase('off-1', accept: false);

      verify(() => mockRepo.respondToOffer('off-1', accept: false)).called(1);
    });

    test('passes offerId correctly', () async {
      when(
        () => mockRepo.respondToOffer(any(), accept: any(named: 'accept')),
      ).thenAnswer((_) async {});

      await useCase('off-xyz', accept: true);

      verify(() => mockRepo.respondToOffer('off-xyz', accept: true)).called(1);
    });
  });
}
