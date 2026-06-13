import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/offers/offers_repository.dart';

/// Drives the offer bubble's Accept / Refuse / Cancel actions through the
/// NestJS backend (`/v1/offers/{id}`), which is the single source of truth for
/// offer state. The backend mirrors the new status back into the Firestore
/// chat message, so the bubble updates itself — no client-side Firestore write.
///
/// Keyed by the backend `offerId` carried in the offer message metadata (NOT
/// the old Firebase callable, which forked order state into Firestore).
class ChatOfferController {
  const ChatOfferController();

  Future<void> handleOffer(bool accepted, String offerId) async {
    if (offerId.isEmpty) return;
    final OffersRepository repo = locator<OffersRepository>();
    if (accepted) {
      await repo.acceptOffer(offerId);
    } else {
      await repo.declineOffer(offerId);
    }
  }

  Future<void> cancelOffer(String offerId) async {
    if (offerId.isEmpty) return;
    await locator<OffersRepository>().cancelOffer(offerId);
  }
}
