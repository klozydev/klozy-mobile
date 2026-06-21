import 'package:json_annotation/json_annotation.dart';

part 'chat_purchase_response.g.dart';

/// Purchase payload embedded under a `purchase`-type message's `purchase` field.
@JsonSerializable()
class ChatPurchaseResponse {
  final String? orderId;
  final String? productName;
  final num? amount;

  const ChatPurchaseResponse({this.orderId, this.productName, this.amount});

  factory ChatPurchaseResponse.fromJson(Map<String, dynamic> json) =>
      _$ChatPurchaseResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ChatPurchaseResponseToJson(this);
}
