import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/chat/domain/chat_repository.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_outgoing_media.dart';
import 'package:klozy/src/feature/chat/domain/entity/media_type.dart';
import 'package:klozy/src/feature/chat/domain/usecase/send_media_message.dart';
import 'package:mocktail/mocktail.dart';

class _MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late _MockChatRepository mockRepo;
  late SendMediaMessage useCase;

  setUpAll(() {
    registerFallbackValue(
      ChatOutgoingMedia(file: File('/tmp/fallback.jpg'), type: MediaType.image),
    );
  });

  setUp(() {
    mockRepo = _MockChatRepository();
    useCase = SendMediaMessage(mockRepo);
  });

  group('SendMediaMessage', () {
    test('delegates to repo.sendMedia with correct args', () async {
      final ChatOutgoingMedia item = ChatOutgoingMedia(
        file: File('/tmp/photo.jpg'),
        type: MediaType.image,
        name: 'photo.jpg',
      );

      when(
        () => mockRepo.sendMedia('thread-1', item, clientId: 'cid-1'),
      ).thenAnswer((_) async {});

      await useCase('thread-1', item, clientId: 'cid-1');

      verify(
        () => mockRepo.sendMedia('thread-1', item, clientId: 'cid-1'),
      ).called(1);
    });

    test('passes clientId correctly', () async {
      final ChatOutgoingMedia item = ChatOutgoingMedia(
        file: File('/tmp/video.mp4'),
        type: MediaType.video,
      );

      when(
        () =>
            mockRepo.sendMedia(any(), any(), clientId: any(named: 'clientId')),
      ).thenAnswer((_) async {});

      await useCase('thread-2', item, clientId: 'cid-xyz');

      verify(
        () => mockRepo.sendMedia('thread-2', item, clientId: 'cid-xyz'),
      ).called(1);
    });
  });
}
