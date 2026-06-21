import 'package:injectable/injectable.dart';
import 'package:klozy/src/feature/chat/domain/chat_repository.dart';

@injectable
class RespondToOffer {
  RespondToOffer(this._repo);

  final ChatRepository _repo;

  Future<void> call(String offerId, {required bool accept}) =>
      _repo.respondToOffer(offerId, accept: accept);
}
