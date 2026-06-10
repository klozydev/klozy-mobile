import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/me/entity/address_input.dart';
import 'package:klozy/src/domain/me/entity/me_profile.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:klozy/src/domain/places/entity/place_details.dart';
import 'package:klozy/src/domain/places/entity/place_suggestion.dart';
import 'package:klozy/src/domain/places/places_repository.dart';
import 'package:klozy/src/feature/onboarding/presentation/bloc/profile_completion_bloc.dart';
import 'package:klozy/src/feature/onboarding/presentation/bloc/profile_completion_event.dart';
import 'package:klozy/src/feature/onboarding/presentation/bloc/profile_completion_state.dart';
import 'package:mocktail/mocktail.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class _MockMeRepository extends Mock implements MeRepository {}

class _MockPlacesRepository extends Mock implements PlacesRepository {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Collects states emitted after dispatching [event]. Waits long enough for the
/// debounce delay (_kDebounce = 350 ms) plus async work to complete.
Future<List<ProfileCompletionState>> _collectStates(
  ProfileCompletionBloc bloc,
  ProfileCompletionEvent event, {
  Duration wait = const Duration(milliseconds: 500),
}) async {
  final states = <ProfileCompletionState>[];
  final sub = bloc.stream.listen(states.add);
  bloc.add(event);
  await Future<void>.delayed(wait);
  await sub.cancel();
  return states;
}

const _fakeSuggestions = <PlaceSuggestion>[
  PlaceSuggestion(placeId: 'id1', description: 'Dubai Marina, Dubai, UAE'),
  PlaceSuggestion(placeId: 'id2', description: 'Downtown Dubai, UAE'),
];

const _fakeDetails = PlaceDetails(
  placeId: 'id1',
  formattedAddress: 'Dubai Marina, Dubai, UAE',
  line1: 'Dubai Marina',
  city: 'Dubai',
  country: 'United Arab Emirates',
);

const _fakeAddress = AddressInput(
  line1: 'Jane',
  city: 'Dubai',
  emirate: 'Dubai',
);

const _fakeMeProfile = MeProfile(
  id: 'u1',
  firstName: 'Jane',
  lastName: 'Doe',
  hasAddress: true,
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _MockMeRepository mockMeRepo;
  late _MockPlacesRepository mockPlacesRepo;
  late ProfileCompletionBloc bloc;

  setUpAll(() {
    registerFallbackValue(_fakeAddress);
  });

  setUp(() {
    mockMeRepo = _MockMeRepository();
    mockPlacesRepo = _MockPlacesRepository();
    bloc = ProfileCompletionBloc(mockMeRepo, mockPlacesRepo);
  });

  tearDown(() => bloc.close());

  // ── Address autocomplete ──────────────────────────────────────────────────

  group('ProfileCompletionAddressQueryChanged', () {
    test(
      'blank query emits SuggestionsCleared without calling Places API',
      () async {
        final states = await _collectStates(
          bloc,
          const ProfileCompletionAddressQueryChanged(''),
        );

        expect(states, [const ProfileCompletionSuggestionsCleared()]);
        verifyNever(() => mockPlacesRepo.autocomplete(any()));
      },
    );

    test('non-blank query after debounce emits SuggestionsLoaded', () async {
      when(
        () => mockPlacesRepo.autocomplete('Dubai'),
      ).thenAnswer((_) async => _fakeSuggestions);

      final states = await _collectStates(
        bloc,
        const ProfileCompletionAddressQueryChanged('Dubai'),
      );

      expect(
        states,
        contains(
          isA<ProfileCompletionSuggestionsLoaded>().having(
            (s) => s.placeIds,
            'placeIds',
            <String>['id1', 'id2'],
          ),
        ),
      );
      verify(() => mockPlacesRepo.autocomplete('Dubai')).called(1);
    });

    test(
      'SuggestionsLoaded maps descriptions to DSAddressSuggestion.main',
      () async {
        when(
          () => mockPlacesRepo.autocomplete('Dubai'),
        ).thenAnswer((_) async => _fakeSuggestions);

        final states = await _collectStates(
          bloc,
          const ProfileCompletionAddressQueryChanged('Dubai'),
        );

        final loaded = states.whereType<ProfileCompletionSuggestionsLoaded>();
        expect(loaded, isNotEmpty);
        final suggestions = loaded.last.suggestions;
        expect(suggestions[0].main, 'Dubai Marina, Dubai, UAE');
        expect(suggestions[1].main, 'Downtown Dubai, UAE');
      },
    );

    test('empty autocomplete result emits SuggestionsCleared', () async {
      when(
        () => mockPlacesRepo.autocomplete(any()),
      ).thenAnswer((_) async => const <PlaceSuggestion>[]);

      final states = await _collectStates(
        bloc,
        const ProfileCompletionAddressQueryChanged('zzz'),
      );

      expect(states, contains(const ProfileCompletionSuggestionsCleared()));
    });

    test('Places API error emits AddressError (no crash)', () async {
      when(
        () => mockPlacesRepo.autocomplete(any()),
      ).thenThrow(Exception('network error'));

      final states = await _collectStates(
        bloc,
        const ProfileCompletionAddressQueryChanged('Dubai'),
      );

      expect(states, contains(const ProfileCompletionAddressError()));
    });

    test('debounce: rapid keystrokes only call Places API once', () async {
      when(
        () => mockPlacesRepo.autocomplete(any()),
      ).thenAnswer((_) async => _fakeSuggestions);

      // Fire 3 events quickly — only the last one should reach the API.
      bloc
        ..add(const ProfileCompletionAddressQueryChanged('D'))
        ..add(const ProfileCompletionAddressQueryChanged('Du'))
        ..add(const ProfileCompletionAddressQueryChanged('Dubai'));

      await Future<void>.delayed(const Duration(milliseconds: 500));

      // Only one call to autocomplete (for the last query that made it through).
      verify(() => mockPlacesRepo.autocomplete(any())).called(1);
    });
  });

  // ── Address selection (details) ───────────────────────────────────────────

  group('ProfileCompletionAddressSelected', () {
    test('emits AddressResolving then AddressResolved on success', () async {
      when(
        () => mockPlacesRepo.details('id1'),
      ).thenAnswer((_) async => _fakeDetails);

      final states = await _collectStates(
        bloc,
        const ProfileCompletionAddressSelected(
          placeId: 'id1',
          displayText: 'Dubai Marina',
        ),
        wait: Duration.zero,
      );

      expect(states, <ProfileCompletionState>[
        const ProfileCompletionAddressResolving(),
        const ProfileCompletionAddressResolved(_fakeDetails),
      ]);
    });

    test(
      'emits AddressResolving then AddressError on details failure',
      () async {
        when(
          () => mockPlacesRepo.details(any()),
        ).thenThrow(Exception('not found'));

        final states = await _collectStates(
          bloc,
          const ProfileCompletionAddressSelected(
            placeId: 'bad-id',
            displayText: 'Unknown',
          ),
          wait: Duration.zero,
        );

        expect(states, <ProfileCompletionState>[
          const ProfileCompletionAddressResolving(),
          const ProfileCompletionAddressError(),
        ]);
      },
    );
  });

  // ── Submit ────────────────────────────────────────────────────────────────

  group('ProfileCompletionSubmitted', () {
    test('emits Submitting then Done on success', () async {
      when(
        () => mockMeRepo.updateProfile(
          firstName: any(named: 'firstName'),
          lastName: any(named: 'lastName'),
          bio: any(named: 'bio'),
        ),
      ).thenAnswer((_) async => _fakeMeProfile);
      when(() => mockMeRepo.setAddress(any())).thenAnswer((_) async {});

      final states = await _collectStates(
        bloc,
        ProfileCompletionSubmitted(
          firstName: 'Jane',
          lastName: 'Doe',
          address: _fakeAddress,
        ),
        wait: Duration.zero,
      );

      expect(states, <ProfileCompletionState>[
        const ProfileCompletionSubmitting(),
        const ProfileCompletionDone(),
      ]);
    });

    test('emits Submitting then Failure on error', () async {
      when(
        () => mockMeRepo.updateProfile(
          firstName: any(named: 'firstName'),
          lastName: any(named: 'lastName'),
          bio: any(named: 'bio'),
        ),
      ).thenThrow(Exception('server error'));

      final states = await _collectStates(
        bloc,
        ProfileCompletionSubmitted(
          firstName: 'Jane',
          lastName: 'Doe',
          address: _fakeAddress,
        ),
        wait: Duration.zero,
      );

      expect(states, hasLength(2));
      expect(states[0], const ProfileCompletionSubmitting());
      expect(states[1], isA<ProfileCompletionFailure>());
    });
  });

  // ── Initial state ─────────────────────────────────────────────────────────

  test('initial state is ProfileCompletionIdle', () {
    expect(bloc.state, const ProfileCompletionIdle());
  });
}
