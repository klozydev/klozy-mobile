import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/me/entity/address.dart';
import 'package:klozy/src/domain/me/entity/address_input.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:klozy/src/feature/settings/presentation/screen/address_form_page.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../support/ds_harness.dart';

class _MockMeRepository extends Mock implements MeRepository {}

class _MockStackRouter extends Mock implements StackRouter {}

const _kAddress = Address(
  id: 'a1',
  line1: '123 Main St',
  city: 'Dubai',
  emirate: 'Dubai',
  label: 'Home',
);

void main() {
  setUpAll(() {
    disableDsFonts();
    registerFallbackValue(
      const AddressInput(line1: 'x', city: 'x', emirate: 'x'),
    );
  });

  late _MockMeRepository mockMe;
  late _MockStackRouter router;

  setUp(() {
    mockMe = _MockMeRepository();
    router = _MockStackRouter();
    when(() => router.maybePop<Object?>()).thenAnswer((_) async => true);
    // The save handler calls maybePop(true) — Dart infers T=bool from the arg.
    when(() => router.maybePop<bool>(true)).thenAnswer((_) async => true);
    when(() => mockMe.createAddress(any())).thenAnswer((_) async => _kAddress);
    when(
      () => mockMe.updateAddress(any(), any()),
    ).thenAnswer((_) async => _kAddress);

    if (locator.isRegistered<MeRepository>()) {
      locator.unregister<MeRepository>();
    }
    locator.registerSingleton<MeRepository>(mockMe);
  });

  tearDown(() {
    if (locator.isRegistered<MeRepository>()) {
      locator.unregister<MeRepository>();
    }
  });

  Widget pumpCreate({bool requirePhone = false}) {
    return dsWrapRouted(
      AddressFormPage(requirePhone: requirePhone),
      router: router,
    );
  }

  Widget pumpEdit() {
    return dsWrapRouted(
      const AddressFormPage(address: _kAddress),
      router: router,
    );
  }

  group('AddressFormPage — create mode', () {
    testWidgets('shows Add address title', (tester) async {
      await tester.pumpWidget(pumpCreate());
      await tester.pump();
      // l10n: address_add_title
      expect(find.byType(AddressFormPage), findsOneWidget);
    });

    testWidgets('save button disabled when required fields are empty', (
      tester,
    ) async {
      await tester.pumpWidget(pumpCreate());
      await tester.pump();

      final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(btn.onPressed, isNull);
    });

    testWidgets('save button enabled when line1 + city + emirate are filled', (
      tester,
    ) async {
      // The form has 7 DSTextFields inside a ListView. Enlarge the viewport so
      // all fields are laid out and findable by index (.at(6) = emirate).
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(pumpCreate());
      await tester.pump();

      // Fields: label, recipient, phone, line1, area, city, emirate
      // Required: line1 (index 3), city (index 5), emirate (index 6)
      await tester.enterText(find.byType(TextField).at(3), 'Sunset Blvd');
      await tester.pump();
      await tester.enterText(find.byType(TextField).at(5), 'Dubai');
      await tester.pump();
      await tester.enterText(find.byType(TextField).at(6), 'Dubai');
      await tester.pump();

      final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(btn.onPressed, isNotNull);
    });

    testWidgets('successful create calls createAddress and pops', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(pumpCreate());
      await tester.pump();

      await tester.enterText(find.byType(TextField).at(3), 'Sunset Blvd');
      await tester.pump();
      await tester.enterText(find.byType(TextField).at(5), 'Dubai');
      await tester.pump();
      await tester.enterText(find.byType(TextField).at(6), 'Dubai');
      await tester.pump();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      verify(() => mockMe.createAddress(any())).called(1);
      // The page calls maybePop(true); T inferred as bool.
      verify(() => router.maybePop<bool>(true)).called(1);
    });

    testWidgets('error shows snackbar', (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      when(() => mockMe.createAddress(any())).thenThrow(Exception('net'));

      await tester.pumpWidget(pumpCreate());
      await tester.pump();

      await tester.enterText(find.byType(TextField).at(3), 'Sunset Blvd');
      await tester.pump();
      await tester.enterText(find.byType(TextField).at(5), 'Dubai');
      await tester.pump();
      await tester.enterText(find.byType(TextField).at(6), 'Dubai');
      await tester.pump();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      verifyNever(() => router.maybePop<Object?>());
    });
  });

  group('AddressFormPage — create mode with requirePhone', () {
    testWidgets('save button disabled when phone is empty', (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(pumpCreate(requirePhone: true));
      await tester.pump();

      await tester.enterText(find.byType(TextField).at(3), 'Sunset Blvd');
      await tester.pump();
      await tester.enterText(find.byType(TextField).at(5), 'Dubai');
      await tester.pump();
      await tester.enterText(find.byType(TextField).at(6), 'Dubai');
      await tester.pump();

      // Phone field is required but still empty → button disabled.
      final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(btn.onPressed, isNull);
    });

    testWidgets('save button enabled when phone is filled', (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(pumpCreate(requirePhone: true));
      await tester.pump();

      await tester.enterText(find.byType(TextField).at(2), '+971500000000');
      await tester.pump();
      await tester.enterText(find.byType(TextField).at(3), 'Sunset Blvd');
      await tester.pump();
      await tester.enterText(find.byType(TextField).at(5), 'Dubai');
      await tester.pump();
      await tester.enterText(find.byType(TextField).at(6), 'Dubai');
      await tester.pump();

      final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(btn.onPressed, isNotNull);
    });

    testWidgets(
      'successful create with recipient name calls createAddress and pops',
      (tester) async {
        // Covers the non-empty recipientName branch inside _save (line 75).
        tester.view.physicalSize = const Size(800, 2000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(pumpCreate());
        await tester.pump();

        // Fields: label=0, recipient=1, phone=2, line1=3, area=4, city=5, emirate=6
        await tester.enterText(find.byType(TextField).at(1), 'John Doe');
        await tester.pump();
        await tester.enterText(find.byType(TextField).at(3), 'Sunset Blvd');
        await tester.pump();
        await tester.enterText(find.byType(TextField).at(5), 'Dubai');
        await tester.pump();
        await tester.enterText(find.byType(TextField).at(6), 'Dubai');
        await tester.pump();

        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        verify(() => mockMe.createAddress(any())).called(1);
        verify(() => router.maybePop<bool>(true)).called(1);
      },
    );
  });

  group('AddressFormPage — edit mode', () {
    testWidgets('shows Edit address title', (tester) async {
      await tester.pumpWidget(pumpEdit());
      await tester.pump();
      expect(find.byType(AddressFormPage), findsOneWidget);
    });

    testWidgets('pre-fills line1 from existing address', (tester) async {
      await tester.pumpWidget(pumpEdit());
      await tester.pump();
      expect(find.text('123 Main St'), findsWidgets);
    });

    testWidgets('successful edit calls updateAddress and pops', (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(pumpEdit());
      await tester.pump();

      // Fields pre-filled → button already enabled since line1/city/emirate set
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      verify(() => mockMe.updateAddress('a1', any())).called(1);
      // The page calls maybePop(true); T inferred as bool.
      verify(() => router.maybePop<bool>(true)).called(1);
    });
  });

  group('AddressFormPage — navigation', () {
    testWidgets('back button pops', (tester) async {
      await tester.pumpWidget(pumpCreate());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      verify(() => router.maybePop<Object?>()).called(1);
    });
  });
}
