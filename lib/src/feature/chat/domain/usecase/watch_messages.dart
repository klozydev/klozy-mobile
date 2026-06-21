import 'package:injectable/injectable.dart';
import 'package:klozy/src/feature/chat/domain/chat_repository.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_message.dart';

@injectable
class WatchMessages {
  WatchMessages(this._repo);

  final ChatRepository _repo;

  Stream<List<ChatMessage>> call(String threadId) =>
      _repo.watchMessages(threadId);
}
