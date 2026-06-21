import 'package:injectable/injectable.dart';
import 'package:klozy/src/feature/chat/domain/chat_repository.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_thread.dart';

@injectable
class WatchThread {
  WatchThread(this._repo);

  final ChatRepository _repo;

  Stream<ChatThread?> call(String threadId) => _repo.watchThread(threadId);
}
