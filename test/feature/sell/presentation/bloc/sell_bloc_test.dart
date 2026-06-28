import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/catalog/catalog_repository.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_category.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_condition.dart';
import 'package:klozy/src/domain/product/entity/create_product_input.dart';
import 'package:klozy/src/domain/product/products_repository.dart';
import 'package:klozy/src/domain/sell/entity/sell_draft.dart';
import 'package:klozy/src/domain/sell/sell_repository.dart';
import 'package:klozy/src/domain/uploads/uploads_repository.dart';
import 'package:klozy/src/feature/sell/domain/entity/sell_draft_field.dart';
import 'package:klozy/src/feature/sell/domain/entity/size_system.dart';
import 'package:klozy/src/feature/sell/presentation/bloc/sell_bloc.dart';
import 'package:klozy/src/feature/sell/presentation/bloc/sell_event.dart';
import 'package:klozy/src/feature/sell/presentation/bloc/sell_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockUploadsRepository extends Mock implements UploadsRepository {}

class _MockSellRepository extends Mock implements SellRepository {}

class _MockProductsRepository extends Mock implements ProductsRepository {}

class _MockCatalogRepository extends Mock implements CatalogRepository {}

class _FakeCreateProductInput extends Fake implements CreateProductInput {}

Future<List<SellState>> _collectStates(SellBloc bloc, SellEvent event) async {
  final states = <SellState>[];
  final sub = bloc.stream.listen(states.add);
  bloc.add(event);
  await Future<void>.delayed(Duration.zero);
  await sub.cancel();
  return states;
}

const _kDraft = SellDraft(
  title: 'Nice Shirt',
  price: 50,
  description: 'Great condition',
);
const _kCategory = CatalogCategory(id: 'cat1', label: 'Women');
const _kCondition = CatalogCondition(slug: 'likeNew', label: 'Like New');

void main() {
  late _MockUploadsRepository mockUploads;
  late _MockSellRepository mockSell;
  late _MockProductsRepository mockProducts;
  late _MockCatalogRepository mockCatalog;
  late SellBloc bloc;

  setUpAll(() {
    registerFallbackValue(_FakeCreateProductInput());
  });

  setUp(() {
    mockUploads = _MockUploadsRepository();
    mockSell = _MockSellRepository();
    mockProducts = _MockProductsRepository();
    mockCatalog = _MockCatalogRepository();
    bloc = SellBloc(mockUploads, mockSell, mockProducts, mockCatalog);
  });

  tearDown(() => bloc.close());

  test('initial state is SellPhotosState([])', () {
    expect(bloc.state, const SellPhotosState(<String>[]));
  });

  group('SellStarted', () {
    test('resets to SellPhotosState', () async {
      final states = await _collectStates(bloc, const SellStarted());
      expect(states.last, const SellPhotosState(<String>[]));
    });
  });

  group('SellPhotosUpdated', () {
    test('emits SellPhotosState with given paths', () async {
      final states = await _collectStates(
        bloc,
        const SellPhotosUpdated(['/img/a.jpg', '/img/b.jpg']),
      );
      final last = states.last as SellPhotosState;
      expect(last.paths, ['/img/a.jpg', '/img/b.jpg']);
    });
  });

  group('SellEditPhotosRequested', () {
    test(
      'returns to SellPhotosState with empty paths when not in recap',
      () async {
        final states = await _collectStates(
          bloc,
          const SellEditPhotosRequested(),
        );
        expect(states.last, const SellPhotosState(<String>[]));
      },
    );

    test('returns SellPhotosState with recap paths when in recap', () async {
      when(() => mockUploads.uploadImages(any())).thenAnswer(
        (_) async => const <String>['https://cdn.example.com/a.jpg'],
      );
      when(() => mockSell.analyze(any())).thenAnswer((_) async => _kDraft);
      when(
        () => mockCatalog.getRootCategories(),
      ).thenAnswer((_) async => const <CatalogCategory>[_kCategory]);
      when(
        () => mockCatalog.getConditions(),
      ).thenAnswer((_) async => const <CatalogCondition>[_kCondition]);
      final sub = bloc.stream.listen((_) {});
      bloc.add(const SellAnalyzeRequested(['/local/a.jpg']));
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      final states = await _collectStates(
        bloc,
        const SellEditPhotosRequested(),
      );

      final photosState = states.last as SellPhotosState;
      expect(photosState.paths, ['/local/a.jpg']);
    });
  });

  group('SellAnalyzeRequested', () {
    test('emits [analyzing, recap] on full success', () async {
      when(() => mockUploads.uploadImages(any())).thenAnswer(
        (_) async => const <String>['https://cdn.example.com/a.jpg'],
      );
      when(() => mockSell.analyze(any())).thenAnswer((_) async => _kDraft);
      when(
        () => mockCatalog.getRootCategories(),
      ).thenAnswer((_) async => const <CatalogCategory>[_kCategory]);
      when(
        () => mockCatalog.getConditions(),
      ).thenAnswer((_) async => const <CatalogCondition>[_kCondition]);

      final states = await _collectStates(
        bloc,
        const SellAnalyzeRequested(['/local/a.jpg']),
      );

      expect(states.first, isA<SellAnalyzingState>());
      final recap = states.last as SellRecapState;
      expect(recap.draft, _kDraft);
      expect(recap.rootCategories, [_kCategory]);
      expect(recap.conditions, [_kCondition]);
      expect(recap.aiFilled, contains(SellDraftField.title));
      expect(recap.aiFilled, contains(SellDraftField.price));
    });

    test('proceeds with empty draft when analyze throws', () async {
      when(() => mockUploads.uploadImages(any())).thenAnswer(
        (_) async => const <String>['https://cdn.example.com/a.jpg'],
      );
      when(() => mockSell.analyze(any())).thenThrow(Exception('AI down'));
      when(
        () => mockCatalog.getRootCategories(),
      ).thenAnswer((_) async => const <CatalogCategory>[]);
      when(
        () => mockCatalog.getConditions(),
      ).thenAnswer((_) async => const <CatalogCondition>[]);

      final states = await _collectStates(
        bloc,
        const SellAnalyzeRequested(['/local/a.jpg']),
      );

      final recap = states.last as SellRecapState;
      expect(recap.draft, SellDraft.empty);
    });

    test('proceeds with empty catalog when getRootCategories throws', () async {
      when(() => mockUploads.uploadImages(any())).thenAnswer(
        (_) async => const <String>['https://cdn.example.com/a.jpg'],
      );
      when(() => mockSell.analyze(any())).thenAnswer((_) async => _kDraft);
      when(
        () => mockCatalog.getRootCategories(),
      ).thenThrow(Exception('network'));
      when(
        () => mockCatalog.getConditions(),
      ).thenAnswer((_) async => const <CatalogCondition>[]);

      final states = await _collectStates(
        bloc,
        const SellAnalyzeRequested(['/local/a.jpg']),
      );

      final recap = states.last as SellRecapState;
      expect(recap.rootCategories, isEmpty);
    });

    test('emits error when uploadImages returns empty', () async {
      when(
        () => mockUploads.uploadImages(any()),
      ).thenAnswer((_) async => const <String>[]);

      final states = await _collectStates(
        bloc,
        const SellAnalyzeRequested(['/local/a.jpg']),
      );

      expect(states.last, isA<SellErrorState>());
    });

    test('emits error when uploadImages throws', () async {
      when(
        () => mockUploads.uploadImages(any()),
      ).thenThrow(Exception('upload'));

      final states = await _collectStates(
        bloc,
        const SellAnalyzeRequested(['/local/a.jpg']),
      );

      expect(states.last, isA<SellErrorState>());
    });

    test('does nothing when paths is empty', () async {
      final states = await _collectStates(
        bloc,
        const SellAnalyzeRequested(<String>[]),
      );
      expect(states, isEmpty);
    });
  });

  group('SellSizeSystemToggled', () {
    Future<void> intoRecap() async {
      when(() => mockUploads.uploadImages(any())).thenAnswer(
        (_) async => const <String>['https://cdn.example.com/a.jpg'],
      );
      when(() => mockSell.analyze(any())).thenAnswer((_) async => _kDraft);
      when(
        () => mockCatalog.getRootCategories(),
      ).thenAnswer((_) async => const <CatalogCategory>[]);
      when(
        () => mockCatalog.getConditions(),
      ).thenAnswer((_) async => const <CatalogCondition>[]);
      final sub = bloc.stream.listen((_) {});
      bloc.add(const SellAnalyzeRequested(['/local/a.jpg']));
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
    }

    test('toggles size system in recap state', () async {
      await intoRecap();
      final states = await _collectStates(
        bloc,
        const SellSizeSystemToggled(SizeSystem.us),
      );
      final recap = states.last as SellRecapState;
      expect(recap.sizeSystem, SizeSystem.us);
    });

    test('does nothing when not in recap state', () async {
      final states = await _collectStates(
        bloc,
        const SellSizeSystemToggled(SizeSystem.us),
      );
      expect(states, isEmpty);
    });
  });

  group('SellDraftFieldEdited', () {
    Future<void> intoRecap() async {
      when(() => mockUploads.uploadImages(any())).thenAnswer(
        (_) async => const <String>['https://cdn.example.com/a.jpg'],
      );
      when(
        () => mockSell.analyze(any()),
      ).thenAnswer((_) async => _kDraft); // title+price+description filled
      when(
        () => mockCatalog.getRootCategories(),
      ).thenAnswer((_) async => const <CatalogCategory>[]);
      when(
        () => mockCatalog.getConditions(),
      ).thenAnswer((_) async => const <CatalogCondition>[]);
      final sub = bloc.stream.listen((_) {});
      bloc.add(const SellAnalyzeRequested(['/local/a.jpg']));
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
    }

    test('removes field from aiFilled when field is in aiFilled', () async {
      await intoRecap();
      final before = (bloc.state as SellRecapState).aiFilled;
      expect(before, contains(SellDraftField.title));

      final states = await _collectStates(
        bloc,
        const SellDraftFieldEdited(SellDraftField.title),
      );

      final recap = states.last as SellRecapState;
      expect(recap.aiFilled, isNot(contains(SellDraftField.title)));
    });

    test('does nothing when field is not in aiFilled', () async {
      await intoRecap();
      final states = await _collectStates(
        bloc,
        const SellDraftFieldEdited(SellDraftField.category),
      );
      expect(states, isEmpty);
    });
  });

  group('SellProductSubmitted', () {
    const kInput = CreateProductInput(
      title: 'Shirt',
      price: 50,
      conditionId: 'c1',
      categoryId: 'cat1',
    );

    Future<void> intoRecap() async {
      when(() => mockUploads.uploadImages(any())).thenAnswer(
        (_) async => const <String>['https://cdn.example.com/a.jpg'],
      );
      when(() => mockSell.analyze(any())).thenAnswer((_) async => _kDraft);
      when(
        () => mockCatalog.getRootCategories(),
      ).thenAnswer((_) async => const <CatalogCategory>[]);
      when(
        () => mockCatalog.getConditions(),
      ).thenAnswer((_) async => const <CatalogCondition>[]);
      final sub = bloc.stream.listen((_) {});
      bloc.add(const SellAnalyzeRequested(['/local/a.jpg']));
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
    }

    test('emits [recap(isCreating=true), done] on success', () async {
      await intoRecap();
      when(
        () => mockProducts.createProduct(any()),
      ).thenAnswer((_) async => 'new-product-id');

      final states = await _collectStates(
        bloc,
        const SellProductSubmitted(kInput),
      );

      final creating = states.first as SellRecapState;
      expect(creating.isCreating, isTrue);
      final done = states.last as SellDoneState;
      expect(done.productId, 'new-product-id');
    });

    test(
      'emits [recap(isCreating=true), recap(isCreating=false, error)] on failure',
      () async {
        await intoRecap();
        when(
          () => mockProducts.createProduct(any()),
        ).thenThrow(Exception('server'));

        final states = await _collectStates(
          bloc,
          const SellProductSubmitted(kInput),
        );

        final creating = states.first as SellRecapState;
        expect(creating.isCreating, isTrue);
        final failed = states.last as SellRecapState;
        expect(failed.isCreating, isFalse);
        expect(failed.submitError, isNotNull);
      },
    );

    test('does nothing when not in recap state', () async {
      final states = await _collectStates(
        bloc,
        const SellProductSubmitted(kInput),
      );
      expect(states, isEmpty);
    });
  });
}
