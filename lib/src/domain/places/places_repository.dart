import 'package:klozy/src/domain/places/entity/place_details.dart';
import 'package:klozy/src/domain/places/entity/place_suggestion.dart';

/// Address autocomplete + resolution. Replaces the hardcoded fake list at
/// `profile_completion_page.dart:21`.
///
/// Transport is intentionally NOT specified here — the implementation may call
/// Google Places directly or go through a backend proxy. That decision is
/// pending and is the impl's concern, not this contract's.
abstract class PlacesRepository {
  /// Predictions for a partial address [query]. Returns empty for blank input.
  Future<List<PlaceSuggestion>> autocomplete(String query);

  /// Resolves a selected suggestion's [placeId] to full [PlaceDetails].
  Future<PlaceDetails> details(String placeId);
}
