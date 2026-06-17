import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:injectable/injectable.dart';
import 'package:klozy/src/data/places/model/place_details_response.dart';
import 'package:klozy/src/data/places/model/place_suggestion_response.dart';

/// Talks to the Klozy API's Places proxy (`/v1/places/*`) rather than Google
/// directly. The server holds an unrestricted Places key; the mobile app no
/// longer ships a platform key (the restricted client keys were what caused the
/// Places web service to reject requests with 4XX).
///
/// The proxy passes Google's JSON through unchanged, so the response parsing
/// (`predictions[]`, `result`) is identical to the legacy web service.
///
/// ## Session tokens
/// A compact token is lazily generated on the first autocomplete call and
/// reused for the session; it's forwarded to the first `details()` call and
/// then reset — Google's recommended one-session billing pattern.
@LazySingleton()
class PlacesRemoteDatasource {
  PlacesRemoteDatasource(this._dio);

  /// Visible for testing — inject a mock Dio.
  @visibleForTesting
  PlacesRemoteDatasource.withDio(this._dio);

  final Dio _dio;

  /// Active session token; null means no session has started yet.
  String? _sessionToken;

  /// Returns autocomplete predictions for [input]. Empty (no network call) when
  /// [input] is blank.
  Future<List<PlaceSuggestionResponse>> autocomplete(String input) async {
    if (input.trim().isEmpty) return const <PlaceSuggestionResponse>[];

    _sessionToken ??= _generateToken();

    final response = await _dio.get<Map<String, dynamic>>(
      'v1/places/autocomplete',
      queryParameters: <String, dynamic>{
        'input': input,
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

  /// Resolves a [placeId] to a [PlaceDetailsResponse]. Forwards and then clears
  /// the current session token.
  Future<PlaceDetailsResponse> details(String placeId) async {
    final token = _sessionToken;
    _sessionToken = null; // reset so the next autocomplete starts a new session

    final response = await _dio.get<Map<String, dynamic>>(
      'v1/places/details',
      queryParameters: <String, dynamic>{
        'placeId': placeId,
        if (token != null) 'sessiontoken': token,
      },
    );

    final data = response.data ?? const <String, dynamic>{};
    _assertResponseStatus(data);

    final result = data['result'];
    if (result is! Map<String, dynamic>) {
      throw StateError(
        'Places details: unexpected payload — "result" is missing or not a '
        'map. place_id=$placeId',
      );
    }

    return PlaceDetailsResponse.fromJson(result);
  }

  /// Throws a [StateError] when the proxied response carries a non-OK status.
  static void _assertResponseStatus(Map<String, dynamic> data) {
    final status = data['status'] as String?;
    if (status != null && status != 'OK' && status != 'ZERO_RESULTS') {
      throw StateError(
        'Places API returned status=$status '
        '(error_message=${data["error_message"]})',
      );
    }
  }

  /// Compact pseudo-UUID for session tokens. Does NOT need to be cryptographic;
  /// Google only requires uniqueness per autocomplete→details session.
  static String _generateToken() {
    final now = DateTime.now().microsecondsSinceEpoch;
    return 'klozy-$now';
  }
}
