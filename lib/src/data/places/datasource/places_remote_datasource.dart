import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:injectable/injectable.dart';
import 'package:klozy/src/data/places/model/place_details_response.dart';
import 'package:klozy/src/data/places/model/place_suggestion_response.dart';

/// Platform-specific keys injected via `--dart-define-from-file=.dart_defines.json`.
const String _kGooglePlacesApiKeyIos = String.fromEnvironment(
  'GOOGLE_PLACES_API_KEY_IOS',
);
const String _kGooglePlacesApiKeyAndroid = String.fromEnvironment(
  'GOOGLE_PLACES_API_KEY_ANDROID',
);

String get _kResolvedApiKey =>
    Platform.isIOS ? _kGooglePlacesApiKeyIos : _kGooglePlacesApiKeyAndroid;

/// Uses the **Legacy Places API** (JSON web service format):
///   - Autocomplete: `GET /maps/api/place/autocomplete/json`
///   - Details:      `GET /maps/api/place/details/json`
///
/// A dedicated Dio instance is created with `maps.googleapis.com` as base URL
/// so it never routes through the app's AuthenticationInterceptor.
///
/// ## Session tokens
/// A compact token is lazily generated when the first autocomplete call of a
/// session fires.  It is reused for all subsequent autocomplete calls of the
/// same session.  On the first `details()` call the token is forwarded to the
/// API and then reset — one token covers N autocomplete + 1 details call,
/// which is Google's recommended billing pattern:
/// https://developers.google.com/maps/documentation/places/web-service/usage-and-billing#ac-sessioning
///
/// ## API key
/// Keys are platform-specific and injected at build time via:
///   `flutter run --dart-define-from-file=.dart_defines.json`
///   `flutter build <target> --dart-define-from-file=.dart_defines.json`
/// Copy `.dart_defines.example.json` to `.dart_defines.json` and fill in your keys.
/// A [StateError] is thrown on the first API call when the key is missing so
/// that a misconfigured build fails fast with a descriptive message.
@lazySingleton
class PlacesRemoteDatasource {
  PlacesRemoteDatasource() : _dio = _buildDio(), _apiKey = _kResolvedApiKey;

  /// Visible for testing — allows injecting a mock Dio and a test key so the
  /// datasource can be constructed without the real --dart-define value.
  @visibleForTesting
  PlacesRemoteDatasource.withDio(Dio dio, {String apiKey = 'test-key'})
    : _dio = dio,
      _apiKey = apiKey;

  final Dio _dio;
  final String _apiKey;

  /// Active session token; null means no session has started yet.
  String? _sessionToken;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Returns autocomplete predictions for [input].
  ///
  /// Returns an empty list without a network call when [input] is blank.
  /// Throws [StateError] when [GOOGLE_PLACES_API_KEY] was not provided at
  /// build time.
  Future<List<PlaceSuggestionResponse>> autocomplete(String input) async {
    _checkApiKey();
    if (input.trim().isEmpty) return const <PlaceSuggestionResponse>[];

    _sessionToken ??= _generateToken();

    final response = await _dio.get<Map<String, dynamic>>(
      'maps/api/place/autocomplete/json',
      queryParameters: <String, dynamic>{
        'input': input,
        'key': _apiKey,
        'sessiontoken': _sessionToken,
      },
    );

    final data = response.data ?? const <String, dynamic>{};
    _assertResponseStatus(data);

    final predictions = data['predictions'];
    if (predictions is! List) return const <PlaceSuggestionResponse>[];

    return predictions
        .whereType<Map<String, dynamic>>()
        .map(PlaceSuggestionResponse.fromJson)
        .toList();
  }

  /// Resolves a [placeId] to a [PlaceDetailsResponse].
  ///
  /// Forwards and then clears the current session token (billing best
  /// practice: one session token covers N autocomplete calls + 1 details call).
  Future<PlaceDetailsResponse> details(String placeId) async {
    _checkApiKey();

    final token = _sessionToken;
    _sessionToken = null; // reset so the next autocomplete starts a new session

    final response = await _dio.get<Map<String, dynamic>>(
      'maps/api/place/details/json',
      queryParameters: <String, dynamic>{
        'place_id': placeId,
        'key': _apiKey,
        // Request only the fields we map — reduces billing cost.
        'fields':
            'place_id,formatted_address,address_components,geometry/location',
        if (token != null) 'sessiontoken': token,
      },
    );

    final data = response.data ?? const <String, dynamic>{};
    _assertResponseStatus(data);

    final result = data['result'];
    if (result is! Map<String, dynamic>) {
      throw StateError(
        'Google Places details: unexpected payload shape — "result" is missing '
        'or not a map. place_id=$placeId',
      );
    }

    return PlaceDetailsResponse.fromJson(result);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static Dio _buildDio() {
    return Dio(
      BaseOptions(
        baseUrl: 'https://maps.googleapis.com/',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
      ),
    );
  }

  void _checkApiKey() {
    if (_apiKey.isEmpty) {
      throw StateError(
        'Google Places API key is not set for this platform. '
        'Run with --dart-define-from-file=.dart_defines.json '
        '(copy .dart_defines.example.json to .dart_defines.json and fill in your keys).',
      );
    }
  }

  /// Throws a [StateError] when the API response carries a non-OK status.
  static void _assertResponseStatus(Map<String, dynamic> data) {
    final status = data['status'] as String?;
    if (status != null && status != 'OK' && status != 'ZERO_RESULTS') {
      throw StateError(
        'Google Places API returned status=$status '
        '(error_message=${data["error_message"]})',
      );
    }
  }

  /// Produces a compact pseudo-UUID suitable for session tokens.
  /// The token does NOT need to be cryptographically random — Google only
  /// requires that it is unique per autocomplete→details session pair.
  static String _generateToken() {
    final now = DateTime.now().microsecondsSinceEpoch;
    return 'klozy-$now';
  }
}
