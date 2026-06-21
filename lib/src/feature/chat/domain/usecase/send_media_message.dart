import 'package:injectable/injectable.dart';
import 'package:klozy/src/feature/chat/domain/chat_repository.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_outgoing_media.dart';

@injectable
class SendMediaMessage {
  SendMediaMessage(this._repo);

  final ChatRepository _repo;

  Future<void> call(
    String threadId,
    ChatOutgoingMedia item, {
    required String clientId,
  }) => _repo.sendMedia(threadId, item, clientId: clientId);
}
