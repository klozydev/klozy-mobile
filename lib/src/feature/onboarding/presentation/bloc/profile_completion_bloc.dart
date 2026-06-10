import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/design/components/ds_address_suggestion.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:klozy/src/domain/places/places_repository.dart';
import 'package:klozy/src/feature/onboarding/presentation/bloc/profile_completion_event.dart';
import 'package:klozy/src/feature/onboarding/presentation/bloc/profile_completion_state.dart';

/// How long to wait after the last keystroke before firing the Places API.
const Duration _kDebounce = Duration(milliseconds: 350);

@injectable
class ProfileCompletionBloc
    extends Bloc<ProfileCompletionEvent, ProfileCompletionState> {
  final MeRepository _meRepository;
  final PlacesRepository _placesRepository;

  ProfileCompletionBloc(this._meRepository, this._placesRepository)
    : super(const ProfileCompletionIdle()) {
    on<ProfileCompletionAddressQueryChanged>(
      _onQueryChanged,
      transformer: restartable(),
    );
    on<ProfileCompletionAddressSelected>(_onAddressSelected);
    on<ProfileCompletionSubmitted>(_onSubmitted);
  }

  // ── Address autocomplete ──────────────────────────────────────────────────

  Future<void> _onQueryChanged(
    ProfileCompletionAddressQueryChanged event,
    Emitter<ProfileCompletionState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      emit(const ProfileCompletionSuggestionsCleared());
      return;
    }

    // Debounce: wait before hitting the API. If another query event arrives
    // while we are waiting, the Bloc's sequential event loop will cancel this
    // handler via the emitter — no extra package needed.
    await Future<void>.delayed(_kDebounce);
    if (emit.isDone) return; // superseded by a newer query event

    try {
      final suggestions = await _placesRepository.autocomplete(query);
      if (emit.isDone) return;

      if (suggestions.isEmpty) {
        emit(const ProfileCompletionSuggestionsCleared());
        return;
      }

      emit(
        ProfileCompletionSuggestionsLoaded(
          suggestions: suggestions
              .map(
                (s) => DSAddressSuggestion(
                  main: s.description,
                  // description already contains the full text; use it for both
                  // fields — the UI shows main as primary and sub as secondary.
                  sub: s.description,
                ),
              )
              .toList(),
          placeIds: suggestions.map((s) => s.placeId).toList(),
        ),
      );
    } catch (_) {
      if (!emit.isDone) emit(const ProfileCompletionAddressError());
    }
  }

  Future<void> _onAddressSelected(
    ProfileCompletionAddressSelected event,
    Emitter<ProfileCompletionState> emit,
  ) async {
    emit(const ProfileCompletionAddressResolving());
    try {
      final details = await _placesRepository.details(event.placeId);
      emit(ProfileCompletionAddressResolved(details));
    } catch (_) {
      emit(const ProfileCompletionAddressError());
    }
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _onSubmitted(
    ProfileCompletionSubmitted event,
    Emitter<ProfileCompletionState> emit,
  ) async {
    emit(const ProfileCompletionSubmitting());
    try {
      await _meRepository.updateProfile(
        firstName: event.firstName,
        lastName: event.lastName,
        bio: event.bio,
      );
      await _meRepository.setAddress(event.address);
      emit(const ProfileCompletionDone());
    } catch (_) {
      emit(
        const ProfileCompletionFailure(
          "Couldn't save your profile. Please try again.",
        ),
      );
    }
  }
}
