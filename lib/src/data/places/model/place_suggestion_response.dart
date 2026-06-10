import 'package:json_annotation/json_annotation.dart';

part 'place_suggestion_response.g.dart';

/// Response model for a single prediction from the Google Places Autocomplete
/// endpoint. Maps the `predictions[]` array items returned by:
///   GET https://maps.googleapis.com/maps/api/place/autocomplete/json
///
/// Only the fields needed to populate [PlaceSuggestion] are declared; the rest
/// are silently ignored by json_serializable.
@JsonSerializable(createToJson: false)
class PlaceSuggestionResponse {
  @JsonKey(name: 'place_id')
  final String placeId;

  final String description;

  const PlaceSuggestionResponse({
    required this.placeId,
    required this.description,
  });

  factory PlaceSuggestionResponse.fromJson(Map<String, dynamic> json) =>
      _$PlaceSuggestionResponseFromJson(json);
}
