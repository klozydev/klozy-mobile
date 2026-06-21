import 'package:injectable/injectable.dart';
import 'package:klozy/src/feature/chat/domain/chat_repository.dart';

@injectable
class MarkThreadSeen {
  MarkThreadSeen(this._repo);

  final ChatRepository _repo;

  Future<void> call(String threadId) => _repo.markSeen(threadId);
}
