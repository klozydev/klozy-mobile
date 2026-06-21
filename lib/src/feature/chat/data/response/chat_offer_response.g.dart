// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_offer_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatOfferResponse _$ChatOfferResponseFromJson(Map<String, dynamic> json) =>
    ChatOfferResponse(
      offerId: json['offerId'] as String?,
      productName: json['productName'] as String?,
      listedPrice: json['listedPrice'] as num?,
      offerPrice: json['offerPrice'] as num?,
      accepted: json['accepted'] as bool?,
      cancelled: json['cancelled'] as bool?,
    );

Map<String, dynamic> _$ChatOfferResponseToJson(ChatOfferResponse instance) =>
    <String, dynamic>{
      'offerId': instance.offerId,
      'productName': instance.productName,
      'listedPrice': instance.listedPrice,
      'offerPrice': instance.offerPrice,
      'accepted': instance.accepted,
      'cancelled': instance.cancelled,
    };
