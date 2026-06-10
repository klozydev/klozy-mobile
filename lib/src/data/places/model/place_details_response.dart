import 'package:json_annotation/json_annotation.dart';

part 'place_details_response.g.dart';

/// Top-level envelope returned by the Google Places Details endpoint:
///   GET https://maps.googleapis.com/maps/api/place/details/json?place_id=...&fields=...
@JsonSerializable(createToJson: false)
class PlaceDetailsResponse {
  @JsonKey(name: 'place_id')
  final String placeId;

  @JsonKey(name: 'formatted_address')
  final String formattedAddress;

  @JsonKey(name: 'address_components')
  final List<AddressComponentResponse> addressComponents;

  final GeometryResponse? geometry;

  const PlaceDetailsResponse({
    required this.placeId,
    required this.formattedAddress,
    required this.addressComponents,
    this.geometry,
  });

  factory PlaceDetailsResponse.fromJson(Map<String, dynamic> json) =>
      _$PlaceDetailsResponseFromJson(json);
}

/// A single component within `address_components[]`.
@JsonSerializable(createToJson: false)
class AddressComponentResponse {
  @JsonKey(name: 'long_name')
  final String longName;

  final List<String> types;

  const AddressComponentResponse({required this.longName, required this.types});

  factory AddressComponentResponse.fromJson(Map<String, dynamic> json) =>
      _$AddressComponentResponseFromJson(json);
}

/// Wraps the `geometry.location` lat/lng.
@JsonSerializable(createToJson: false)
class GeometryResponse {
  final LocationResponse? location;

  const GeometryResponse({this.location});

  factory GeometryResponse.fromJson(Map<String, dynamic> json) =>
      _$GeometryResponseFromJson(json);
}

/// Latitude and longitude returned inside `geometry.location`.
@JsonSerializable(createToJson: false)
class LocationResponse {
  final double lat;
  final double lng;

  const LocationResponse({required this.lat, required this.lng});

  factory LocationResponse.fromJson(Map<String, dynamic> json) =>
      _$LocationResponseFromJson(json);
}
