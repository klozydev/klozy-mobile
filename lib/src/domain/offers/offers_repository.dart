/// Offers on cart buckets (`/v1/offers`).
abstract class OffersRepository {
  /// `POST /v1/offers` — one offer covering a seller's whole bucket.
  Future<void> makeOffer({required String sellerId, required num amount});

  /// `DELETE /v1/offers/{id}` — cancel my pending offer.
  Future<void> cancelOffer(String offerId);
}
