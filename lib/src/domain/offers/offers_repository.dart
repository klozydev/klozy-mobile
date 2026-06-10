import 'package:klozy/src/domain/offers/entity/offer.dart';

/// Offers on cart buckets (`/v1/offers`).
abstract class OffersRepository {
  /// `GET /v1/offers?box=incoming|outgoing`.
  Future<List<Offer>> listOffers({required bool incoming});

  /// `POST /v1/offers` — one offer covering a seller's whole bucket.
  Future<void> makeOffer({required String sellerId, required num amount});

  /// `DELETE /v1/offers/{id}` — cancel my pending offer.
  Future<void> cancelOffer(String offerId);

  /// `POST /v1/offers/{id}/accept` (seller).
  Future<void> acceptOffer(String offerId);

  /// `POST /v1/offers/{id}/decline` (seller).
  Future<void> declineOffer(String offerId);
}
