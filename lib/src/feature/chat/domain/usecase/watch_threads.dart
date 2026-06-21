import 'package:injectable/injectable.dart';
import 'package:klozy/src/feature/chat/domain/chat_repository.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_thread.dart';

@injectable
class WatchThreads {
  WatchThreads(this._repo);

  final ChatRepository _repo;

  Stream<List<ChatThread>> call() => _repo.watchThreads();
}
