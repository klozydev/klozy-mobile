import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:klozy/src/design/components/ds_address_suggestion.dart';
import 'package:klozy/src/domain/places/entity/place_details.dart';

@immutable
sealed class ProfileCompletionState extends Equatable {
  const ProfileCompletionState();

  @override
  List<Object?> get props => [];
}

// ── Submit states ─────────────────────────────────────────────────────────────

final class ProfileCompletionIdle extends ProfileCompletionState {
  const ProfileCompletionIdle();
}

final class ProfileCompletionSubmitting extends ProfileCompletionState {
  const ProfileCompletionSubmitting();
}

final class ProfileCompletionDone extends ProfileCompletionState {
  const ProfileCompletionDone();
}

final class ProfileCompletionFailure extends ProfileCompletionState {
  final String message;

  const ProfileCompletionFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// ── Address autocomplete states ───────────────────────────────────────────────

/// Autocomplete suggestions ready for display. [suggestions] is the
/// [DSAddressSuggestion] list for [DSAddressField]; [placeIds] is the parallel
/// list of opaque placeIds used to resolve details on selection.
final class ProfileCompletionSuggestionsLoaded extends ProfileCompletionState {
  final List<DSAddressSuggestion> suggestions;
  final List<String> placeIds;

  const ProfileCompletionSuggestionsLoaded({
    required this.suggestions,
    required this.placeIds,
  });

  @override
  List<Object?> get props => [suggestions, placeIds];
}

/// Suggestions list cleared (blank query or after a selection).
final class ProfileCompletionSuggestionsCleared extends ProfileCompletionState {
  const ProfileCompletionSuggestionsCleared();
}

/// Resolving full [PlaceDetails] after the user picked a suggestion.
final class ProfileCompletionAddressResolving extends ProfileCompletionState {
  const ProfileCompletionAddressResolving();
}

/// [PlaceDetails] resolved — the page can now populate the address field and
/// unlock the submit button.
final class ProfileCompletionAddressResolved extends ProfileCompletionState {
  final PlaceDetails details;

  const ProfileCompletionAddressResolved(this.details);

  @override
  List<Object?> get props => [details];
}

/// Autocomplete or details fetch failed — the page shows a graceful fallback
/// (no crash; the user can keep typing).
final class ProfileCompletionAddressError extends ProfileCompletionState {
  const ProfileCompletionAddressError();
}
