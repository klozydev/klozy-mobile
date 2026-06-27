import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/chat/domain/chat_repository.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_outgoing_media.dart';
import 'package:klozy/src/feature/chat/domain/entity/media_type.dart';
import 'package:klozy/src/feature/chat/domain/usecase/send_audio_message.dart';
import 'package:mocktail/mocktail.dart';

class _MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late _MockChatRepository mockRepo;
  late SendAudioMessage useCase;

  setUpAll(() {
    registerFallbackValue(
      ChatOutgoingMedia(file: File('/tmp/fallback.m4a'), type: MediaType.audio),
    );
  });

  setUp(() {
    mockRepo = _MockChatRepository();
    useCase = SendAudioMessage(mockRepo);
  });

  group('SendAudioMessage', () {
    test('delegates to repo.sendAudio with correct args', () async {
      final ChatOutgoingMedia audio = ChatOutgoingMedia(
        file: File('/tmp/voice.m4a'),
        type: MediaType.audio,
        durationMs: 5000,
      );

      when(
        () => mockRepo.sendAudio('thread-1', audio, clientId: 'cid-1'),
      ).thenAnswer((_) async {});

      await useCase('thread-1', audio, clientId: 'cid-1');

      verify(
        () => mockRepo.sendAudio('thread-1', audio, clientId: 'cid-1'),
      ).called(1);
    });

    test('passes clientId correctly', () async {
      final ChatOutgoingMedia audio = ChatOutgoingMedia(
        file: File('/tmp/note.m4a'),
        type: MediaType.audio,
      );

      when(
        () =>
            mockRepo.sendAudio(any(), any(), clientId: any(named: 'clientId')),
      ).thenAnswer((_) async {});

      await useCase('thread-2', audio, clientId: 'cid-abc');

      verify(
        () => mockRepo.sendAudio('thread-2', audio, clientId: 'cid-abc'),
      ).called(1);
    });
  });
}
