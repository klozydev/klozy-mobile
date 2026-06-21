import 'package:equatable/equatable.dart';

/// Offer-bubble payload, read from a message's `metadata` map.
///
/// Offer state lives in the NestJS backend (`/v1/offers/{id}`); the backend
/// mirrors status changes back into this Firestore metadata, so the bubble
/// reflects [accepted] / [cancelled] without a client write.
class OfferData extends Equatable {
  final String offerId;
  final String productName;

  /// The product's listed (original) price.
  final num listedPrice;

  /// The offered amount.
  final num offerPrice;

  /// `null` while pending, `true` accepted, `false` refused.
  final bool? accepted;
  final bool cancelled;

  const OfferData({
    required this.offerId,
    required this.productName,
    required this.listedPrice,
    required this.offerPrice,
    this.accepted,
    this.cancelled = false,
  });

  bool get isPending => accepted == null && !cancelled;
  bool get isAccepted => accepted == true;
  bool get isRefused => accepted == false || cancelled;

  @override
  List<Object?> get props => <Object?>[
    offerId,
    productName,
    listedPrice,
    offerPrice,
    accepted,
    cancelled,
  ];
}
