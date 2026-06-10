import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/data/places/datasource/places_remote_datasource.dart';
import 'package:klozy/src/data/places/mapper/places_mapper.dart';
import 'package:klozy/src/data/places/model/place_details_response.dart';
import 'package:klozy/src/data/places/model/place_suggestion_response.dart';
import 'package:klozy/src/data/places/places_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class _MockPlacesRemoteDatasource extends Mock
    implements PlacesRemoteDatasource {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

PlaceDetailsResponse _fakeDetailsResponse() => PlaceDetailsResponse(
  placeId: 'ChIJABC',
  formattedAddress: '1 Rue Test, 75001 Paris, France',
  addressComponents: <AddressComponentResponse>[
    const AddressComponentResponse(
      longName: '1',
      types: <String>['street_number'],
    ),
    const AddressComponentResponse(
      longName: 'Rue Test',
      types: <String>['route'],
    ),
    const AddressComponentResponse(
      longName: 'Paris',
      types: <String>['locality', 'political'],
    ),
    const AddressComponentResponse(
      longName: '75001',
      types: <String>['postal_code'],
    ),
    const AddressComponentResponse(
      longName: 'France',
      types: <String>['country', 'political'],
    ),
  ],
  geometry: GeometryResponse(
    location: const LocationResponse(lat: 48.8566, lng: 2.3522),
  ),
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _MockPlacesRemoteDatasource mockDatasource;
  late PlacesRepositoryImpl repository;

  setUp(() {
    mockDatasource = _MockPlacesRemoteDatasource();
    repository = PlacesRepositoryImpl(mockDatasource, const PlacesMapper());
  });

  // -------------------------------------------------------------------------
  // autocomplete
  // -------------------------------------------------------------------------

  group('PlacesRepositoryImpl.autocomplete', () {
    test(
      'returns empty list without calling datasource for blank query',
      () async {
        when(
          () => mockDatasource.autocomplete(any()),
        ).thenAnswer((_) async => const <PlaceSuggestionResponse>[]);

        final result = await repository.autocomplete('');

        expect(result, isEmpty);
        // The datasource is still called here — the short-circuit lives inside
        // the datasource, not the repo. The repo always delegates.
        verify(() => mockDatasource.autocomplete('')).called(1);
      },
    );

    test('maps datasource responses to PlaceSuggestion entities', () async {
      when(() => mockDatasource.autocomplete('Paris')).thenAnswer(
        (_) async => <PlaceSuggestionResponse>[
          const PlaceSuggestionResponse(
            placeId: 'ChIJD7',
            description: 'Paris, France',
          ),
          const PlaceSuggestionResponse(
            placeId: 'ChIJXX',
            description: 'Paris, TX, USA',
          ),
        ],
      );

      final result = await repository.autocomplete('Paris');

      expect(result, hasLength(2));
      expect(result[0].placeId, 'ChIJD7');
      expect(result[0].description, 'Paris, France');
      expect(result[1].placeId, 'ChIJXX');
      expect(result[1].description, 'Paris, TX, USA');
    });

    test('propagates datasource exceptions', () async {
      when(
        () => mockDatasource.autocomplete(any()),
      ).thenThrow(StateError('API error'));

      expect(
        () => repository.autocomplete('Paris'),
        throwsA(isA<StateError>()),
      );
    });
  });

  // -------------------------------------------------------------------------
  // details
  // -------------------------------------------------------------------------

  group('PlacesRepositoryImpl.details', () {
    test('maps datasource response to PlaceDetails entity', () async {
      when(
        () => mockDatasource.details('ChIJABC'),
      ).thenAnswer((_) async => _fakeDetailsResponse());

      final result = await repository.details('ChIJABC');

      expect(result.placeId, 'ChIJABC');
      expect(result.formattedAddress, '1 Rue Test, 75001 Paris, France');
      expect(result.line1, '1 Rue Test');
      expect(result.city, 'Paris');
      expect(result.postalCode, '75001');
      expect(result.country, 'France');
      expect(result.latitude, 48.8566);
      expect(result.longitude, 2.3522);
    });

    test('propagates datasource exceptions', () async {
      when(
        () => mockDatasource.details(any()),
      ).thenThrow(StateError('place not found'));

      expect(() => repository.details('bad'), throwsA(isA<StateError>()));
    });
  });
}
