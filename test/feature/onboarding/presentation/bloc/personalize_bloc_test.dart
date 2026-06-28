import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/catalog/catalog_repository.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_brand.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_category.dart';
import 'package:klozy/src/domain/me/entity/preferences_input.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:klozy/src/feature/onboarding/presentation/bloc/personalize_bloc.dart';
import 'package:klozy/src/feature/onboarding/presentation/bloc/personalize_event.dart';
import 'package:klozy/src/feature/onboarding/presentation/bloc/personalize_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockCatalogRepository extends Mock implements CatalogRepository {}

class _MockMeRepository extends Mock implements MeRepository {}

Future<List<PersonalizeState>> _collectStates(
  PersonalizeBloc bloc,
  PersonalizeEvent event,
) async {
  final states = <PersonalizeState>[];
  final sub = bloc.stream.listen(states.add);
  bloc.add(event);
  await Future<void>.delayed(Duration.zero);
  await sub.cancel();
  return states;
}

const _kCategory = CatalogCategory(id: 'cat1', label: 'Women');
const _kBrand = CatalogBrand(id: 'b1', name: 'Nike');
const _kPrefs = PreferencesInput(sizeSystem: 'EU');

void main() {
  late _MockCatalogRepository mockCatalog;
  late _MockMeRepository mockMe;
  late PersonalizeBloc bloc;

  setUpAll(() {
    registerFallbackValue(_kPrefs);
  });

  setUp(() {
    mockCatalog = _MockCatalogRepository();
    mockMe = _MockMeRepository();
    bloc = PersonalizeBloc(mockCatalog, mockMe);
  });

  tearDown(() => bloc.close());

  test('initial state is PersonalizeLoading', () {
    expect(bloc.state, const PersonalizeLoading());
  });

  group('PersonalizeStarted', () {
    test('emits [loading, ready] on success', () async {
      when(
        () => mockCatalog.getRootCategories(),
      ).thenAnswer((_) async => <CatalogCategory>[_kCategory]);
      when(
        () => mockCatalog.searchBrands(query: any(named: 'query')),
      ).thenAnswer((_) async => <CatalogBrand>[_kBrand]);

      final states = await _collectStates(bloc, const PersonalizeStarted());

      expect(states.first, const PersonalizeLoading());
      final ready = states.last as PersonalizeReady;
      expect(ready.categories, [_kCategory]);
      expect(ready.brands, [_kBrand]);
    });

    test('emits [loading, failure] on error', () async {
      when(
        () => mockCatalog.getRootCategories(),
      ).thenThrow(Exception('network'));

      final states = await _collectStates(bloc, const PersonalizeStarted());

      expect(states.first, const PersonalizeLoading());
      expect(states.last, isA<PersonalizeFailure>());
    });
  });

  group('PersonalizeBrandQueryChanged', () {
    Future<void> startBloc() async {
      when(
        () => mockCatalog.getRootCategories(),
      ).thenAnswer((_) async => <CatalogCategory>[_kCategory]);
      when(
        () => mockCatalog.searchBrands(query: any(named: 'query')),
      ).thenAnswer((_) async => <CatalogBrand>[_kBrand]);
      final sub = bloc.stream.listen((_) {});
      bloc.add(const PersonalizeStarted());
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
    }

    test('updates brands list on query change', () async {
      await startBloc();
      const newBrand = CatalogBrand(id: 'b2', name: 'Adidas');
      when(
        () => mockCatalog.searchBrands(query: 'adidas'),
      ).thenAnswer((_) async => <CatalogBrand>[newBrand]);

      final states = await _collectStates(
        bloc,
        const PersonalizeBrandQueryChanged('adidas'),
      );

      final ready = states.first as PersonalizeReady;
      expect(ready.brands, [newBrand]);
    });

    test('passes null query when query is whitespace', () async {
      await startBloc();
      // startBloc() already triggered a default searchBrands() (query: null);
      // reset so we only count the call from the whitespace event.
      clearInteractions(mockCatalog);
      when(
        () => mockCatalog.searchBrands(query: null),
      ).thenAnswer((_) async => <CatalogBrand>[_kBrand]);

      await _collectStates(bloc, const PersonalizeBrandQueryChanged('  '));

      verify(() => mockCatalog.searchBrands(query: null)).called(1);
    });

    test('silently keeps current brands on error', () async {
      await startBloc();
      when(
        () => mockCatalog.searchBrands(query: any(named: 'query')),
      ).thenThrow(Exception('search fail'));

      final states = await _collectStates(
        bloc,
        const PersonalizeBrandQueryChanged('q'),
      );

      expect(states, isEmpty); // no state change on error
    });

    test('does nothing when state is not ready', () async {
      // State is still PersonalizeLoading
      final states = await _collectStates(
        bloc,
        const PersonalizeBrandQueryChanged('q'),
      );
      expect(states, isEmpty);
    });
  });

  group('PersonalizeSubmitted', () {
    test('emits [ready(submitting), completed] on success', () async {
      when(
        () => mockCatalog.getRootCategories(),
      ).thenAnswer((_) async => <CatalogCategory>[_kCategory]);
      when(
        () => mockCatalog.searchBrands(query: any(named: 'query')),
      ).thenAnswer((_) async => <CatalogBrand>[_kBrand]);
      final startSub = bloc.stream.listen((_) {});
      bloc.add(const PersonalizeStarted());
      await Future<void>.delayed(Duration.zero);
      await startSub.cancel();

      when(() => mockMe.updatePreferences(any())).thenAnswer((_) async {});

      final states = await _collectStates(
        bloc,
        const PersonalizeSubmitted(_kPrefs),
      );

      expect(states.first, isA<PersonalizeReady>());
      expect((states.first as PersonalizeReady).isSubmitting, isTrue);
      expect(states.last, const PersonalizeCompleted());
    });

    test('proceeds to completed even when updatePreferences throws', () async {
      when(
        () => mockMe.updatePreferences(any()),
      ).thenThrow(Exception('server'));

      final states = await _collectStates(
        bloc,
        const PersonalizeSubmitted(_kPrefs),
      );

      expect(states.last, const PersonalizeCompleted());
    });
  });
}
