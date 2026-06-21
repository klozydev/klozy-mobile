// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_purchase_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatPurchaseResponse _$ChatPurchaseResponseFromJson(
  Map<String, dynamic> json,
) => ChatPurchaseResponse(
  orderId: json['orderId'] as String?,
  productName: json['productName'] as String?,
  amount: json['amount'] as num?,
);

Map<String, dynamic> _$ChatPurchaseResponseToJson(
  ChatPurchaseResponse instance,
) => <String, dynamic>{
  'orderId': instance.orderId,
  'productName': instance.productName,
  'amount': instance.amount,
};
