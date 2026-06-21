import 'package:injectable/injectable.dart';
import 'package:klozy/src/feature/chat/domain/chat_repository.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_outgoing_media.dart';

@injectable
class SendAudioMessage {
  SendAudioMessage(this._repo);

  final ChatRepository _repo;

  Future<void> call(
    String threadId,
    ChatOutgoingMedia audio, {
    required String clientId,
  }) => _repo.sendAudio(threadId, audio, clientId: clientId);
}
