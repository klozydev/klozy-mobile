import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/components/ds_selectable_chip.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/catalog/catalog_repository.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_brand.dart';
import 'package:klozy/src/domain/me/entity/preferences_input.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:klozy/src/feature/settings/presentation/screen/preferred_brands_page.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../support/ds_harness.dart';

class _MockMeRepository extends Mock implements MeRepository {}

class _MockCatalogRepository extends Mock implements CatalogRepository {}

class _MockStackRouter extends Mock implements StackRouter {}

const _kPrefs = PreferencesInput(brandIds: <String>['b1']);
const _kBrands = <CatalogBrand>[
  CatalogBrand(id: 'b1', name: 'Nike'),
  CatalogBrand(id: 'b2', name: 'Adidas'),
];

void main() {
  setUpAll(() {
    disableDsFonts();
    registerFallbackValue(const PreferencesInput());
  });

  late _MockMeRepository mockMe;
  late _MockCatalogRepository mockCatalog;
  late _MockStackRouter router;

  setUp(() {
    mockMe = _MockMeRepository();
    mockCatalog = _MockCatalogRepository();
    router = _MockStackRouter();

    when(() => mockMe.getPreferences()).thenAnswer((_) async => _kPrefs);
    when(() => mockMe.updatePreferences(any())).thenAnswer((_) async {});
    when(
      () => mockCatalog.searchBrands(query: any(named: 'query')),
    ).thenAnswer((_) async => _kBrands);

    when(() => router.maybePop<Object?>()).thenAnswer((_) async => true);

    if (locator.isRegistered<MeRepository>()) {
      locator.unregister<MeRepository>();
    }
    if (locator.isRegistered<CatalogRepository>()) {
      locator.unregister<CatalogRepository>();
    }
    locator.registerSingleton<MeRepository>(mockMe);
    locator.registerSingleton<CatalogRepository>(mockCatalog);
  });

  tearDown(() {
    if (locator.isRegistered<MeRepository>()) {
      locator.unregister<MeRepository>();
    }
    if (locator.isRegistered<CatalogRepository>()) {
      locator.unregister<CatalogRepository>();
    }
  });

  Widget pump() {
    return dsWrapRouted(const PreferredBrandsPage(), router: router);
  }

  group('PreferredBrandsPage — loading', () {
    testWidgets('shows DSLoader while loading', (tester) async {
      final completer = Completer<PreferencesInput>();
      when(() => mockMe.getPreferences()).thenAnswer((_) => completer.future);

      await tester.pumpWidget(pump());
      await tester.pump();

      expect(find.byType(DSLoader), findsOneWidget);
    });

    testWidgets('shows brand chips after load completes', (tester) async {
      await tester.pumpWidget(pump());
      await tester.pumpAndSettle();

      expect(find.byType(DSLoader), findsNothing);
      expect(find.byType(DSSelectableChip), findsWidgets);
      expect(find.text('Nike'), findsOneWidget);
      expect(find.text('Adidas'), findsOneWidget);
    });
  });

  group('PreferredBrandsPage — interaction', () {
    testWidgets('brand chip appears selected for pre-selected brand', (
      tester,
    ) async {
      await tester.pumpWidget(pump());
      await tester.pumpAndSettle();

      // b1 (Nike) is in _kPrefs.brandIds so it should be selected.
      final nikeChip = tester.widget<DSSelectableChip>(
        find
            .ancestor(
              of: find.text('Nike'),
              matching: find.byType(DSSelectableChip),
            )
            .first,
      );
      expect(nikeChip.selected, isTrue);
    });

    testWidgets('tapping unselected chip marks it selected', (tester) async {
      await tester.pumpWidget(pump());
      await tester.pumpAndSettle();

      // Adidas (b2) is not selected initially.
      await tester.tap(
        find
            .ancestor(
              of: find.text('Adidas'),
              matching: find.byType(DSSelectableChip),
            )
            .first,
      );
      await tester.pump();

      final adidasChip = tester.widget<DSSelectableChip>(
        find
            .ancestor(
              of: find.text('Adidas'),
              matching: find.byType(DSSelectableChip),
            )
            .first,
      );
      expect(adidasChip.selected, isTrue);
    });

    testWidgets('tapping selected chip deselects it', (tester) async {
      await tester.pumpWidget(pump());
      await tester.pumpAndSettle();

      // Nike (b1) is selected initially → tap to deselect.
      await tester.tap(
        find
            .ancestor(
              of: find.text('Nike'),
              matching: find.byType(DSSelectableChip),
            )
            .first,
      );
      await tester.pump();

      final nikeChip = tester.widget<DSSelectableChip>(
        find
            .ancestor(
              of: find.text('Nike'),
              matching: find.byType(DSSelectableChip),
            )
            .first,
      );
      expect(nikeChip.selected, isFalse);
    });

    testWidgets('search field triggers searchBrands', (tester) async {
      await tester.pumpWidget(pump());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Nik');
      await tester.pumpAndSettle();

      verify(
        () => mockCatalog.searchBrands(query: 'Nik'),
      ).called(greaterThanOrEqualTo(1));
    });
  });

  group('PreferredBrandsPage — save', () {
    testWidgets('save button calls updatePreferences and pops', (tester) async {
      await tester.pumpWidget(pump());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      verify(() => mockMe.updatePreferences(any())).called(1);
      verify(() => router.maybePop<Object?>()).called(1);
    });

    testWidgets('save error shows snackbar', (tester) async {
      when(() => mockMe.updatePreferences(any())).thenThrow(Exception('net'));

      await tester.pumpWidget(pump());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      verifyNever(() => router.maybePop<Object?>());
    });
  });

  group('PreferredBrandsPage — navigation', () {
    testWidgets('back button pops', (tester) async {
      await tester.pumpWidget(pump());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      verify(() => router.maybePop<Object?>()).called(1);
    });
  });
}
