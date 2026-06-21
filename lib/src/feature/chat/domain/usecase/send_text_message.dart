import 'package:injectable/injectable.dart';
import 'package:klozy/src/feature/chat/domain/chat_repository.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_message.dart';

@injectable
class SendTextMessage {
  SendTextMessage(this._repo);

  final ChatRepository _repo;

  Future<void> call(
    String threadId,
    String text, {
    required String clientId,
    ChatMessage? replyTo,
  }) => _repo.sendText(threadId, text, clientId: clientId, replyTo: replyTo);
}
