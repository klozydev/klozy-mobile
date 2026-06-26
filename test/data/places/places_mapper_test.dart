import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/data/places/mapper/places_mapper.dart';
import 'package:klozy/src/data/places/model/place_details_response.dart';
import 'package:klozy/src/data/places/model/place_suggestion_response.dart';

void main() {
  const mapper = PlacesMapper();

  // -------------------------------------------------------------------------
  // toSuggestion
  // -------------------------------------------------------------------------

  group('PlacesMapper.toSuggestion', () {
    test('maps placeId and description correctly', () {
      const response = PlaceSuggestionResponse(
        placeId: 'ChIJABC',
        description: 'Paris, France',
      );

      final suggestion = mapper.toSuggestion(response);

      expect(suggestion.placeId, 'ChIJABC');
      expect(suggestion.description, 'Paris, France');
    });
  });

  // -------------------------------------------------------------------------
  // toDetails — full payload
  // -------------------------------------------------------------------------

  group('PlacesMapper.toDetails — full payload', () {
    test('maps all fields correctly when all components are present', () {
      const response = PlaceDetailsResponse(
        placeId: 'ChIJD7fiBh9u5kcRYJSMaMOCCwQ',
        formattedAddress: '12 Rue de Rivoli, 75001 Paris, France',
        addressComponents: <AddressComponentResponse>[
          AddressComponentResponse(
            longName: '12',
            types: <String>['street_number'],
          ),
          AddressComponentResponse(
            longName: 'Rue de Rivoli',
            types: <String>['route'],
          ),
          AddressComponentResponse(
            longName: 'Paris',
            types: <String>['locality', 'political'],
          ),
          AddressComponentResponse(
            longName: '75001',
            types: <String>['postal_code'],
          ),
          AddressComponentResponse(
            longName: 'France',
            types: <String>['country', 'political'],
          ),
        ],
        geometry: GeometryResponse(
          location: LocationResponse(lat: 48.8566, lng: 2.3522),
        ),
      );

      final details = mapper.toDetails(response);

      expect(details.placeId, 'ChIJD7fiBh9u5kcRYJSMaMOCCwQ');
      expect(details.formattedAddress, '12 Rue de Rivoli, 75001 Paris, France');
      expect(details.line1, '12 Rue de Rivoli');
      expect(details.city, 'Paris');
      expect(details.postalCode, '75001');
      expect(details.country, 'France');
      expect(details.latitude, 48.8566);
      expect(details.longitude, 2.3522);
    });

    test('line1 is route-only when street_number is absent', () {
      const response = PlaceDetailsResponse(
        placeId: 'xyz',
        formattedAddress: 'Rue de la Paix, Paris',
        addressComponents: <AddressComponentResponse>[
          AddressComponentResponse(
            longName: 'Rue de la Paix',
            types: <String>['route'],
          ),
          AddressComponentResponse(
            longName: 'Paris',
            types: <String>['locality', 'political'],
          ),
        ],
      );

      final details = mapper.toDetails(response);

      expect(details.line1, 'Rue de la Paix');
      expect(details.city, 'Paris');
    });

    test('line1 is null when both street_number and route are absent', () {
      const response = PlaceDetailsResponse(
        placeId: 'xyz',
        formattedAddress: 'Paris, France',
        addressComponents: <AddressComponentResponse>[
          AddressComponentResponse(
            longName: 'Paris',
            types: <String>['locality', 'political'],
          ),
        ],
      );

      final details = mapper.toDetails(response);

      expect(details.line1, isNull);
    });

    test(
      'city falls back to administrative_area_level_2 when locality absent',
      () {
        const response = PlaceDetailsResponse(
          placeId: 'xyz',
          formattedAddress: 'Countryside, UK',
          addressComponents: <AddressComponentResponse>[
            AddressComponentResponse(
              longName: 'Surrey',
              types: <String>['administrative_area_level_2', 'political'],
            ),
            AddressComponentResponse(
              longName: 'United Kingdom',
              types: <String>['country', 'political'],
            ),
          ],
        );

        final details = mapper.toDetails(response);

        expect(details.city, 'Surrey');
      },
    );

    test('latitude and longitude are null when geometry is absent', () {
      const response = PlaceDetailsResponse(
        placeId: 'xyz',
        formattedAddress: 'Somewhere',
        addressComponents: <AddressComponentResponse>[],
      );

      final details = mapper.toDetails(response);

      expect(details.latitude, isNull);
      expect(details.longitude, isNull);
    });
  });
}
