import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/components/ds_selectable_chip.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/catalog/catalog_repository.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_category.dart';
import 'package:klozy/src/domain/me/entity/preferences_input.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:klozy/src/feature/settings/presentation/screen/clothing_preference_page.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../support/ds_harness.dart';

class _MockMeRepository extends Mock implements MeRepository {}

class _MockCatalogRepository extends Mock implements CatalogRepository {}

class _MockStackRouter extends Mock implements StackRouter {}

const _kPrefs = PreferencesInput(categoryIds: <String>['cat1']);
const _kRootCategories = <CatalogCategory>[
  CatalogCategory(id: 'cat1', label: 'Women'),
  CatalogCategory(id: 'cat2', label: 'Men'),
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
      () => mockCatalog.getRootCategories(),
    ).thenAnswer((_) async => _kRootCategories);

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
    return dsWrapRouted(const ClothingPreferencePage(), router: router);
  }

  group('ClothingPreferencePage — loading', () {
    testWidgets('shows DSLoader while loading', (tester) async {
      final completer = Completer<PreferencesInput>();
      when(() => mockMe.getPreferences()).thenAnswer((_) => completer.future);

      await tester.pumpWidget(pump());
      await tester.pump();

      expect(find.byType(DSLoader), findsOneWidget);
    });

    testWidgets('hides DSLoader after load', (tester) async {
      await tester.pumpWidget(pump());
      await tester.pumpAndSettle();

      expect(find.byType(DSLoader), findsNothing);
    });
  });

  group('ClothingPreferencePage — content', () {
    testWidgets('shows add-category chip after load', (tester) async {
      await tester.pumpWidget(pump());
      await tester.pumpAndSettle();

      expect(find.byType(DSSelectableChip), findsWidgets);
    });

    testWidgets('shows pre-selected category label Women', (tester) async {
      await tester.pumpWidget(pump());
      await tester.pumpAndSettle();

      // cat1 (Women) is in _kPrefs.categoryIds and getRootCategories maps it
      // to the label 'Women'.
      expect(find.text('Women'), findsOneWidget);
    });

    testWidgets('tapping a selected category chip removes it', (tester) async {
      await tester.pumpWidget(pump());
      await tester.pumpAndSettle();

      // 'Women' chip (cat1) is pre-selected; tapping it deselects/removes it.
      await tester.tap(
        find
            .ancestor(
              of: find.text('Women'),
              matching: find.byType(DSSelectableChip),
            )
            .first,
      );
      await tester.pump();

      expect(find.text('Women'), findsNothing);
    });
  });

  group('ClothingPreferencePage — save', () {
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

  group('ClothingPreferencePage — navigation', () {
    testWidgets('back button pops', (tester) async {
      await tester.pumpWidget(pump());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      verify(() => router.maybePop<Object?>()).called(1);
    });
  });
}
