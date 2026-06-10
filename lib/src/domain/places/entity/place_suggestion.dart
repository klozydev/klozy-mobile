import 'package:equatable/equatable.dart';

/// A single address autocomplete suggestion (Google Places "prediction").
/// [placeId] is opaque and is later resolved to full [PlaceDetails].
class PlaceSuggestion extends Equatable {
  final String placeId;
  final String description;

  const PlaceSuggestion({required this.placeId, required this.description});

  @override
  List<Object?> get props => <Object?>[placeId, description];
}
