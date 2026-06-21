import 'package:injectable/injectable.dart';
import 'package:klozy/src/feature/chat/domain/chat_repository.dart';

@injectable
class ReportAndBlock {
  ReportAndBlock(this._repo);

  final ChatRepository _repo;

  Future<void> call(String threadId, String otherUserId) =>
      _repo.reportAndBlock(threadId, otherUserId);
}
