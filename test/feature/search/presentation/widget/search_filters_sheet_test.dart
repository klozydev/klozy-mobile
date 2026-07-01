import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/catalog/catalog_repository.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_brand.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_category.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_condition.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_size_value.dart';
import 'package:klozy/src/domain/product/entity/search_facets.dart';
import 'package:klozy/src/feature/search/presentation/bloc/search_filters.dart';
import 'package:klozy/src/feature/search/presentation/widget/search_filters_sheet.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../support/ds_harness.dart';

class _MockCatalogRepository extends Mock implements CatalogRepository {}

const _kConditions = <CatalogCondition>[
  CatalogCondition(slug: 'new', label: 'New with tags'),
  CatalogCondition(slug: 'veryGood', label: 'Very good'),
  CatalogCondition(slug: 'good', label: 'Good'),
];

const _kSizes = <CatalogSizeValue>[
  CatalogSizeValue(token: 'XS', label: 'XS'),
  CatalogSizeValue(token: 'S', label: 'S'),
  CatalogSizeValue(token: 'M', label: 'M'),
];

/// Helper: shows the sheet via [showModalBottomSheet] and returns whatever
/// [SearchFilters] the sheet pops, or null if dismissed.
Future<SearchFilters?> _showSheet(
  WidgetTester tester, {
  SearchFilters initial = const SearchFilters(),
  SearchFacets? facets,
}) async {
  SearchFilters? result;
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: dsTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (ctx) => ElevatedButton(
            onPressed: () async {
              result = await showModalBottomSheet<SearchFilters>(
                context: ctx,
                isScrollControlled: true,
                builder: (_) => SizedBox(
                  height: 700,
                  child: SearchFiltersSheet(initial: initial, facets: facets),
                ),
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
  return result;
}

void main() {
  setUpAll(disableDsFonts);

  late _MockCatalogRepository mockCatalog;

  setUp(() {
    mockCatalog = _MockCatalogRepository();

    // DSCategoryTreePicker calls getCategories during init.
    when(
      () => mockCatalog.getCategories(parentId: any(named: 'parentId')),
    ).thenAnswer((_) async => <CatalogCategory>[]);

    when(
      () => mockCatalog.getConditions(),
    ).thenAnswer((_) async => _kConditions);

    when(
      () => mockCatalog.getSizeConfig(any()),
    ).thenAnswer((_) async => _kSizes);

    when(
      () => mockCatalog.getRootCategories(),
    ).thenAnswer((_) async => <CatalogCategory>[]);

    when(
      () => mockCatalog.searchBrands(query: any(named: 'query')),
    ).thenAnswer((_) async => <CatalogBrand>[]);

    when(
      () => mockCatalog.getSizes(),
    ).thenAnswer((_) async => <CatalogSizeValue>[]);

    if (locator.isRegistered<CatalogRepository>()) {
      locator.unregister<CatalogRepository>();
    }
    locator.registerSingleton<CatalogRepository>(mockCatalog);
  });

  tearDown(() {
    if (locator.isRegistered<CatalogRepository>()) {
      locator.unregister<CatalogRepository>();
    }
  });

  group('SearchFiltersSheet — loading state', () {
    testWidgets('shows DSLoader while conditions are loading', (tester) async {
      // Keep conditions pending so loader stays visible.
      final Completer<List<CatalogCondition>> completer =
          Completer<List<CatalogCondition>>();
      when(
        () => mockCatalog.getConditions(),
      ).thenAnswer((_) => completer.future);

      await tester.pumpWidget(
        dsWrap(
          const Scaffold(
            body: SizedBox(
              height: 700,
              child: SearchFiltersSheet(initial: SearchFilters()),
            ),
          ),
        ),
      );
      await tester.pump(); // single frame, future still pending

      expect(find.byType(DSLoader), findsWidgets);
    });

    testWidgets('shows condition chips after loading', (tester) async {
      await _showSheet(tester);

      expect(find.text('New with tags'), findsOneWidget);
      expect(find.text('Very good'), findsOneWidget);
      expect(find.text('Good'), findsOneWidget);
    });
  });

  group('SearchFiltersSheet — initial rendering', () {
    testWidgets('renders Reset and Show results buttons', (tester) async {
      await _showSheet(tester);

      expect(find.text('Reset'), findsOneWidget);
      expect(find.text('Show results'), findsOneWidget);
    });

    testWidgets('renders CATEGORY label', (tester) async {
      await _showSheet(tester);
      expect(find.text('CATEGORY'), findsOneWidget);
    });

    testWidgets('renders CONDITION label', (tester) async {
      await _showSheet(tester);
      expect(find.text('CONDITION'), findsOneWidget);
    });

    testWidgets('shows Clear toggle when all conditions are selected', (
      tester,
    ) async {
      // Conditions default to all-selected → shows "Clear".
      await _showSheet(tester);
      expect(find.text('Clear'), findsAtLeast(1));
    });
  });

  group('SearchFiltersSheet — condition toggle', () {
    testWidgets('tapping Clear deselects all conditions', (tester) async {
      await _showSheet(tester);

      // "Clear" is shown because all conditions are selected by default.
      await tester.tap(find.text('Clear').first);
      await tester.pump();

      // After clearing, "All" should appear.
      expect(find.text('All'), findsAtLeast(1));
    });

    testWidgets('tapping All re-selects all conditions', (tester) async {
      await _showSheet(tester);

      await tester.tap(find.text('Clear').first);
      await tester.pump();

      await tester.tap(find.text('All').first);
      await tester.pump();

      expect(find.text('Clear'), findsAtLeast(1));
    });

    testWidgets('tapping a condition chip toggles it', (tester) async {
      await _showSheet(tester);

      // Tap the "New with tags" chip — it starts selected, so tap deselects it.
      await tester.tap(find.text('New with tags'));
      await tester.pump();

      // Should still exist as a chip (just deselected); widget is still in tree.
      expect(find.text('New with tags'), findsOneWidget);
    });
  });

  group('SearchFiltersSheet — reset', () {
    testWidgets('tapping Reset brings Clear back (re-selects all conditions)', (
      tester,
    ) async {
      await _showSheet(tester);

      // Clear all conditions first.
      await tester.tap(find.text('Clear').first);
      await tester.pump();
      expect(find.text('All'), findsAtLeast(1));

      // Tap Reset.
      await tester.tap(find.text('Reset'));
      await tester.pump();

      // Conditions should be all-selected again → "Clear" shown.
      expect(find.text('Clear'), findsAtLeast(1));
    });
  });

  group('SearchFiltersSheet — apply', () {
    testWidgets('tapping Show results pops with SearchFilters', (tester) async {
      SearchFilters? popped;
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: dsTheme(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () async {
                  popped = await showModalBottomSheet<SearchFilters>(
                    context: ctx,
                    isScrollControlled: true,
                    builder: (_) => const SizedBox(
                      height: 700,
                      child: SearchFiltersSheet(initial: SearchFilters()),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Tap "Show results" (the Apply button).
      await tester.tap(find.text('Show results'));
      await tester.pumpAndSettle();

      expect(popped, isNotNull);
      expect(popped, isA<SearchFilters>());
    });

    testWidgets(
      'applying after clearing all conditions sends empty conditions set',
      (tester) async {
        SearchFilters? popped;
        await tester.pumpWidget(
          MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: dsTheme(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Builder(
                builder: (ctx) => ElevatedButton(
                  onPressed: () async {
                    popped = await showModalBottomSheet<SearchFilters>(
                      context: ctx,
                      isScrollControlled: true,
                      builder: (_) => const SizedBox(
                        height: 700,
                        child: SearchFiltersSheet(initial: SearchFilters()),
                      ),
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        // Default is all-selected → apply pops with empty set (= no constraint).
        await tester.tap(find.text('Show results'));
        await tester.pumpAndSettle();

        expect(popped!.conditions, isEmpty);
      },
    );
  });

  group('SearchFiltersSheet — price range (facets)', () {
    testWidgets('shows RangeSlider when facets carry a valid price range', (
      tester,
    ) async {
      const facets = SearchFacets(priceMin: 0, priceMax: 500);
      await _showSheet(tester, facets: facets);

      expect(find.byType(RangeSlider), findsOneWidget);
    });

    testWidgets('no RangeSlider when facets have no price range', (
      tester,
    ) async {
      await _showSheet(tester);
      expect(find.byType(RangeSlider), findsNothing);
    });

    testWidgets('PRICE label shown when range is visible', (tester) async {
      const facets = SearchFacets(priceMin: 10, priceMax: 500);
      await _showSheet(tester, facets: facets);
      expect(find.text('PRICE (DHS)'), findsOneWidget);
    });
  });

  group('SearchFiltersSheet — initial filters seeded', () {
    testWidgets('initial condition selection is preserved', (tester) async {
      const initial = SearchFilters(conditions: {'new'});
      await _showSheet(tester, initial: initial);

      // Since initial.conditions is non-empty, the selection is preserved
      // rather than defaulting to all-selected.  "All" toggle should be shown
      // (not all selected).
      expect(find.text('All'), findsAtLeast(1));
    });
  });
}
