import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:klozy/src/domain/me/entity/address_input.dart';

@immutable
sealed class ProfileCompletionEvent extends Equatable {
  const ProfileCompletionEvent();

  @override
  List<Object?> get props => [];
}

/// User typed in the address field — triggers debounced autocomplete.
final class ProfileCompletionAddressQueryChanged
    extends ProfileCompletionEvent {
  final String query;

  const ProfileCompletionAddressQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

/// User tapped a suggestion — resolve full [PlaceDetails] for the [placeId].
final class ProfileCompletionAddressSelected extends ProfileCompletionEvent {
  final String placeId;
  final String displayText;

  const ProfileCompletionAddressSelected({
    required this.placeId,
    required this.displayText,
  });

  @override
  List<Object?> get props => [placeId, displayText];
}

/// Final submit: persist profile + address to the backend.
final class ProfileCompletionSubmitted extends ProfileCompletionEvent {
  final String firstName;
  final String lastName;
  final String? bio;
  final AddressInput address;

  const ProfileCompletionSubmitted({
    required this.firstName,
    required this.lastName,
    required this.address,
    this.bio,
  });

  @override
  List<Object?> get props => [firstName, lastName, bio, address];
}
