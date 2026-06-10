// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_details_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlaceDetailsResponse _$PlaceDetailsResponseFromJson(
  Map<String, dynamic> json,
) => PlaceDetailsResponse(
  placeId: json['place_id'] as String,
  formattedAddress: json['formatted_address'] as String,
  addressComponents: (json['address_components'] as List<dynamic>)
      .map((e) => AddressComponentResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
  geometry: json['geometry'] == null
      ? null
      : GeometryResponse.fromJson(json['geometry'] as Map<String, dynamic>),
);

AddressComponentResponse _$AddressComponentResponseFromJson(
  Map<String, dynamic> json,
) => AddressComponentResponse(
  longName: json['long_name'] as String,
  types: (json['types'] as List<dynamic>).map((e) => e as String).toList(),
);

GeometryResponse _$GeometryResponseFromJson(Map<String, dynamic> json) =>
    GeometryResponse(
      location: json['location'] == null
          ? null
          : LocationResponse.fromJson(json['location'] as Map<String, dynamic>),
    );

LocationResponse _$LocationResponseFromJson(Map<String, dynamic> json) =>
    LocationResponse(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
