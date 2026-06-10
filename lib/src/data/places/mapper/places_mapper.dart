import 'package:injectable/injectable.dart';
import 'package:klozy/src/data/places/model/place_details_response.dart';
import 'package:klozy/src/data/places/model/place_suggestion_response.dart';
import 'package:klozy/src/domain/places/entity/place_details.dart';
import 'package:klozy/src/domain/places/entity/place_suggestion.dart';

/// Stateless mapper — response models → domain entities.
@injectable
class PlacesMapper {
  const PlacesMapper();

  PlaceSuggestion toSuggestion(PlaceSuggestionResponse response) {
    return PlaceSuggestion(
      placeId: response.placeId,
      description: response.description,
    );
  }

  PlaceDetails toDetails(PlaceDetailsResponse response) {
    final components = response.addressComponents;

    final city =
        _findComponent(components, const <String>['locality', 'postal_town']) ??
        _findComponent(components, const <String>[
          'administrative_area_level_2',
        ]);

    final postalCode = _findComponent(components, const <String>[
      'postal_code',
    ]);

    final country = _findComponent(components, const <String>['country']);

    final streetNumber = _findComponent(components, const <String>[
      'street_number',
    ]);
    final route = _findComponent(components, const <String>['route']);
    final line1 = _buildLine1(streetNumber, route);

    final lat = response.geometry?.location?.lat;
    final lng = response.geometry?.location?.lng;

    return PlaceDetails(
      placeId: response.placeId,
      formattedAddress: response.formattedAddress,
      line1: line1,
      city: city,
      postalCode: postalCode,
      country: country,
      latitude: lat,
      longitude: lng,
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Returns the `long_name` of the first component that matches any of the
  /// given [types]. Returns null when none match.
  String? _findComponent(
    List<AddressComponentResponse> components,
    List<String> types,
  ) {
    for (final component in components) {
      for (final type in types) {
        if (component.types.contains(type)) {
          return component.longName.isEmpty ? null : component.longName;
        }
      }
    }
    return null;
  }

  String? _buildLine1(String? streetNumber, String? route) {
    if (streetNumber != null && route != null) {
      return '$streetNumber $route';
    }
    if (route != null) return route;
    return null;
  }
}
