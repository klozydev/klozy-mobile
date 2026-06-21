import 'package:json_annotation/json_annotation.dart';

part 'chat_offer_response.g.dart';

/// Offer payload embedded under an `offer`-type message's `offer` field.
@JsonSerializable()
class ChatOfferResponse {
  final String? offerId;
  final String? productName;
  final num? listedPrice;
  final num? offerPrice;
  final bool? accepted;
  final bool? cancelled;

  const ChatOfferResponse({
    this.offerId,
    this.productName,
    this.listedPrice,
    this.offerPrice,
    this.accepted,
    this.cancelled,
  });

  factory ChatOfferResponse.fromJson(Map<String, dynamic> json) =>
      _$ChatOfferResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ChatOfferResponseToJson(this);
}
