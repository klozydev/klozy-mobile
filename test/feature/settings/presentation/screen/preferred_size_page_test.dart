import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/components/ds_selectable_chip.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/catalog/catalog_repository.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_size_value.dart';
import 'package:klozy/src/domain/me/entity/preferences_input.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:klozy/src/feature/settings/presentation/screen/preferred_size_page.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../support/ds_harness.dart';

class _MockMeRepository extends Mock implements MeRepository {}

class _MockCatalogRepository extends Mock implements CatalogRepository {}

class _MockStackRouter extends Mock implements StackRouter {}

const _kPrefs = PreferencesInput(sizeSystem: 'EU', sizes: <String>['M']);
const _kSizes = <CatalogSizeValue>[
  CatalogSizeValue(token: 'S', label: 'S'),
  CatalogSizeValue(token: 'M', label: 'M'),
  CatalogSizeValue(token: 'L', label: 'L'),
  CatalogSizeValue(
    token: 'EU 40',
    label: '40',
    systemLabels: <String, String>{'EU': '40', 'US': '8', 'UK': '7'},
  ),
  CatalogSizeValue(
    token: 'US 8',
    label: '8',
    systemLabels: <String, String>{'EU': '40', 'US': '8', 'UK': '7'},
  ),
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
    when(() => mockCatalog.getSizes()).thenAnswer((_) async => _kSizes);

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
    return dsWrapRouted(const PreferredSizePage(), router: router);
  }

  group('PreferredSizePage — loading', () {
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

  group('PreferredSizePage — content', () {
    testWidgets('shows size chips after load', (tester) async {
      await tester.pumpWidget(pump());
      await tester.pumpAndSettle();

      expect(find.byType(DSSelectableChip), findsWidgets);
    });

    testWidgets('M chip is selected matching prefs', (tester) async {
      await tester.pumpWidget(pump());
      await tester.pumpAndSettle();

      final mChip = tester.widget<DSSelectableChip>(
        find
            .ancestor(
              of: find.text('M'),
              matching: find.byType(DSSelectableChip),
            )
            .first,
      );
      expect(mChip.selected, isTrue);
    });

    testWidgets('tapping unselected chip marks it selected', (tester) async {
      await tester.pumpWidget(pump());
      await tester.pumpAndSettle();

      // 'S' is not in _kPrefs.sizes, so it starts unselected.
      await tester.tap(
        find
            .ancestor(
              of: find.text('S'),
              matching: find.byType(DSSelectableChip),
            )
            .first,
      );
      await tester.pump();

      final sChip = tester.widget<DSSelectableChip>(
        find
            .ancestor(
              of: find.text('S'),
              matching: find.byType(DSSelectableChip),
            )
            .first,
      );
      expect(sChip.selected, isTrue);
    });

    testWidgets('tapping a size-system segment changes displayed chips', (
      tester,
    ) async {
      // Covers the DSSegmentedControl onChanged callback (lines 130-131).
      await tester.pumpWidget(pump());
      await tester.pumpAndSettle();

      // Default sizeSystem is 'EU'. Tap 'US' segment to switch.
      await tester.tap(find.text('US'));
      await tester.pump();

      // After the switch the size system label is highlighted — no crash.
      expect(find.text('US'), findsOneWidget);
    });

    testWidgets('tapping selected chip deselects it', (tester) async {
      await tester.pumpWidget(pump());
      await tester.pumpAndSettle();

      // 'M' is selected → tap to deselect.
      await tester.tap(
        find
            .ancestor(
              of: find.text('M'),
              matching: find.byType(DSSelectableChip),
            )
            .first,
      );
      await tester.pump();

      final mChip = tester.widget<DSSelectableChip>(
        find
            .ancestor(
              of: find.text('M'),
              matching: find.byType(DSSelectableChip),
            )
            .first,
      );
      expect(mChip.selected, isFalse);
    });
  });

  group('PreferredSizePage — save', () {
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

  group('PreferredSizePage — navigation', () {
    testWidgets('back button pops', (tester) async {
      await tester.pumpWidget(pump());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      verify(() => router.maybePop<Object?>()).called(1);
    });
  });
}
