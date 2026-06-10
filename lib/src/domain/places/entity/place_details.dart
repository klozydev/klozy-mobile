import 'package:equatable/equatable.dart';

/// Resolved address for a selected [PlaceSuggestion]. Shape is deliberately
/// aligned with `AddressInput` fields so onboarding can map it directly.
///
/// Fields are nullable because Places coverage varies by locale; the onboarding
/// form fills the gaps. Final field set is OWNED by business-dev once the
/// Google-vs-proxy decision lands — treat this as a starting contract.
class PlaceDetails extends Equatable {
  final String placeId;
  final String formattedAddress;
  final String? line1;
  final String? city;
  final String? postalCode;
  final String? country;
  final double? latitude;
  final double? longitude;

  const PlaceDetails({
    required this.placeId,
    required this.formattedAddress,
    this.line1,
    this.city,
    this.postalCode,
    this.country,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => <Object?>[
    placeId,
    formattedAddress,
    line1,
    city,
    postalCode,
    country,
    latitude,
    longitude,
  ];
}
