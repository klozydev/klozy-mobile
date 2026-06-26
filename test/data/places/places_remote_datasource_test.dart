import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/data/places/datasource/places_remote_datasource.dart';
import 'package:mocktail/mocktail.dart';

// ---------------------------------------------------------------------------
// Fakes & mocks
// ---------------------------------------------------------------------------

class _MockDio extends Mock implements Dio {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Creates a fake Dio [Response] wrapping [data].
Response<Map<String, dynamic>> _ok(Map<String, dynamic> data) =>
    Response<Map<String, dynamic>>(
      data: data,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    );

/// Stubs a GET call on [dio] so it returns [data].
void _stubGet(_MockDio dio, Map<String, dynamic> data) {
  when(
    () => dio.get<Map<String, dynamic>>(
      any(),
      queryParameters: any(named: 'queryParameters'),
      options: any(named: 'options'),
    ),
  ).thenAnswer((_) async => _ok(data));
}

PlacesRemoteDatasource _datasource(_MockDio dio) =>
    PlacesRemoteDatasource.withDio(dio);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _MockDio mockDio;

  setUpAll(() {
    // Datasource passes `options: cacheable('places')`, so any() on the
    // `options` named arg needs a registered fallback of the Options type.
    registerFallbackValue(Options());
  });

  setUp(() {
    mockDio = _MockDio();
  });

  // -------------------------------------------------------------------------
  // autocomplete — empty / blank input short-circuit
  // -------------------------------------------------------------------------

  group('autocomplete — blank input short-circuit', () {
    test('returns [] without any network call for empty string', () async {
      final ds = _datasource(mockDio);
      final result = await ds.autocomplete('');
      expect(result, isEmpty);
      verifyNever(
        () => mockDio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      );
    });

    test(
      'returns [] without any network call for whitespace-only input',
      () async {
        final ds = _datasource(mockDio);
        final result = await ds.autocomplete('   ');
        expect(result, isEmpty);
        verifyNever(
          () => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        );
      },
    );
  });

  // -------------------------------------------------------------------------
  // autocomplete — successful mapping
  // -------------------------------------------------------------------------

  group('autocomplete — successful response mapping', () {
    test(
      'parses predictions list and returns PlaceSuggestionResponse list',
      () async {
        _stubGet(mockDio, <String, dynamic>{
          'status': 'OK',
          'predictions': <dynamic>[
            <String, dynamic>{
              'place_id': 'ChIJD7fiBh9u5kcRYJSMaMOCCwQ',
              'description': 'Paris, France',
            },
            <String, dynamic>{
              'place_id': 'ChIJXXXX',
              'description': 'Paris, TX, USA',
            },
          ],
        });

        final ds = _datasource(mockDio);
        final result = await ds.autocomplete('Paris');

        expect(result, hasLength(2));
        expect(result[0].placeId, 'ChIJD7fiBh9u5kcRYJSMaMOCCwQ');
        expect(result[0].description, 'Paris, France');
        expect(result[1].placeId, 'ChIJXXXX');
        expect(result[1].description, 'Paris, TX, USA');
      },
    );

    test('returns [] when predictions is absent from payload', () async {
      _stubGet(mockDio, <String, dynamic>{'status': 'ZERO_RESULTS'});
      final ds = _datasource(mockDio);
      final result = await ds.autocomplete('zzzzzzz');
      expect(result, isEmpty);
    });

    test('passes sessiontoken in subsequent autocomplete calls', () async {
      _stubGet(mockDio, <String, dynamic>{
        'status': 'OK',
        'predictions': <dynamic>[],
      });

      final ds = _datasource(mockDio);
      await ds.autocomplete('Par');
      await ds.autocomplete('Paris');

      // Both calls must include a sessiontoken.
      final calls = verify(
        () => mockDio.get<Map<String, dynamic>>(
          any(),
          queryParameters: captureAny(named: 'queryParameters'),
          options: any(named: 'options'),
        ),
      ).captured;

      expect(calls, hasLength(2));
      final token0 =
          (calls[0] as Map<String, dynamic>)['sessiontoken'] as String?;
      final token1 =
          (calls[1] as Map<String, dynamic>)['sessiontoken'] as String?;
      expect(token0, isNotEmpty);
      expect(token1, equals(token0), reason: 'same session token reused');
    });
  });

  // -------------------------------------------------------------------------
  // details — successful mapping
  // -------------------------------------------------------------------------

  group('details — successful response mapping', () {
    test('parses result and returns PlaceDetailsResponse', () async {
      _stubGet(mockDio, <String, dynamic>{
        'status': 'OK',
        'result': <String, dynamic>{
          'place_id': 'ChIJD7fiBh9u5kcRYJSMaMOCCwQ',
          'formatted_address': '75001 Paris, France',
          'address_components': <dynamic>[
            <String, dynamic>{
              'long_name': 'Paris',
              'types': <dynamic>['locality', 'political'],
            },
            <String, dynamic>{
              'long_name': '75001',
              'types': <dynamic>['postal_code'],
            },
            <String, dynamic>{
              'long_name': 'France',
              'types': <dynamic>['country', 'political'],
            },
          ],
          'geometry': <String, dynamic>{
            'location': <String, dynamic>{'lat': 48.8566, 'lng': 2.3522},
          },
        },
      });

      final ds = _datasource(mockDio);
      final result = await ds.details('ChIJD7fiBh9u5kcRYJSMaMOCCwQ');

      expect(result.placeId, 'ChIJD7fiBh9u5kcRYJSMaMOCCwQ');
      expect(result.formattedAddress, '75001 Paris, France');
      expect(result.addressComponents, hasLength(3));
      expect(result.geometry?.location?.lat, 48.8566);
      expect(result.geometry?.location?.lng, 2.3522);
    });

    test('resets session token after details call', () async {
      // First autocomplete to set a token.
      when(
        () => mockDio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async =>
            _ok(<String, dynamic>{'status': 'OK', 'predictions': <dynamic>[]}),
      );
      final ds = _datasource(mockDio);
      await ds.autocomplete('Paris');

      // Now details call should forward the token.
      when(
        () => mockDio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => _ok(<String, dynamic>{
          'status': 'OK',
          'result': <String, dynamic>{
            'place_id': 'abc',
            'formatted_address': 'Paris',
            'address_components': <dynamic>[],
          },
        }),
      );

      await ds.details('abc');

      // A second autocomplete should start a NEW session token.
      when(
        () => mockDio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async =>
            _ok(<String, dynamic>{'status': 'OK', 'predictions': <dynamic>[]}),
      );

      await ds.autocomplete('Paris 2');

      final allCalls = verify(
        () => mockDio.get<Map<String, dynamic>>(
          any(),
          queryParameters: captureAny(named: 'queryParameters'),
          options: any(named: 'options'),
        ),
      ).captured;

      // calls: autocomplete1, details, autocomplete2
      expect(allCalls, hasLength(3));
      final firstToken =
          (allCalls[0] as Map<String, dynamic>)['sessiontoken'] as String?;
      final detailsToken =
          (allCalls[1] as Map<String, dynamic>)['sessiontoken'] as String?;
      final secondToken =
          (allCalls[2] as Map<String, dynamic>)['sessiontoken'] as String?;

      expect(firstToken, isNotEmpty);
      expect(
        detailsToken,
        equals(firstToken),
        reason: 'details must carry the autocomplete session token',
      );
      expect(
        secondToken,
        isNot(equals(firstToken)),
        reason: 'new autocomplete session starts a fresh token',
      );
    });

    test('throws StateError when result field is missing', () {
      _stubGet(mockDio, <String, dynamic>{'status': 'OK'});
      final ds = _datasource(mockDio);
      expect(() => ds.details('bad-id'), throwsA(isA<StateError>()));
    });

    test('throws StateError when API returns non-OK status', () {
      _stubGet(mockDio, <String, dynamic>{
        'status': 'REQUEST_DENIED',
        'error_message': 'The provided API key is invalid.',
      });
      final ds = _datasource(mockDio);
      expect(
        () => ds.details('any'),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('REQUEST_DENIED'),
          ),
        ),
      );
    });
  });
}
