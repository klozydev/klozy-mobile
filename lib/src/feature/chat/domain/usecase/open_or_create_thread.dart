import 'package:injectable/injectable.dart';
import 'package:klozy/src/feature/chat/domain/chat_repository.dart';

@injectable
class OpenOrCreateThread {
  OpenOrCreateThread(this._repo);

  final ChatRepository _repo;

  Future<String?> call(
    String otherUserId, {
    String? displayName,
    String? avatarUrl,
  }) => _repo.openOrCreateThread(
    otherUserId,
    displayName: displayName,
    avatarUrl: avatarUrl,
  );
}
