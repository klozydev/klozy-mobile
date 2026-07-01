import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/me/entity/address.dart';
import 'package:klozy/src/domain/me/entity/address_input.dart';
import 'package:klozy/src/domain/me/entity/me_profile.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:klozy/src/domain/places/places_repository.dart';
import 'package:klozy/src/feature/settings/presentation/screen/edit_profile_page.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../support/ds_harness.dart';

class _MockMeRepository extends Mock implements MeRepository {}

class _MockPlacesRepository extends Mock implements PlacesRepository {}

class _MockStackRouter extends Mock implements StackRouter {}

const _kMe = MeProfile(
  id: 'u1',
  firstName: 'Alice',
  lastName: 'Smith',
  hasAddress: false,
);

const _kMeWithAddress = MeProfile(
  id: 'u1',
  firstName: 'Alice',
  lastName: 'Smith',
  hasAddress: true,
);

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
  late _MockPlacesRepository mockPlaces;
  late _MockStackRouter router;

  setUp(() {
    mockMe = _MockMeRepository();
    mockPlaces = _MockPlacesRepository();
    router = _MockStackRouter();

    when(() => mockMe.getMe()).thenAnswer((_) async => _kMe);
    when(() => mockMe.getAddresses()).thenAnswer((_) async => <Address>[]);
    when(
      () => mockMe.updateProfile(
        firstName: any(named: 'firstName'),
        lastName: any(named: 'lastName'),
        bio: any(named: 'bio'),
      ),
    ).thenAnswer((_) async => _kMe);
    when(() => mockMe.setAddress(any())).thenAnswer((_) async {});
    when(() => mockMe.uploadAvatar(any())).thenAnswer((_) async => null);

    when(() => router.maybePop<Object?>()).thenAnswer((_) async => true);

    if (locator.isRegistered<MeRepository>()) {
      locator.unregister<MeRepository>();
    }
    if (locator.isRegistered<PlacesRepository>()) {
      locator.unregister<PlacesRepository>();
    }
    if (locator.isRegistered<EventBus>()) {
      locator.unregister<EventBus>();
    }
    locator.registerSingleton<MeRepository>(mockMe);
    locator.registerSingleton<PlacesRepository>(mockPlaces);
    locator.registerSingleton<EventBus>(EventBus());
  });

  tearDown(() {
    if (locator.isRegistered<MeRepository>()) {
      locator.unregister<MeRepository>();
    }
    if (locator.isRegistered<PlacesRepository>()) {
      locator.unregister<PlacesRepository>();
    }
    if (locator.isRegistered<EventBus>()) {
      locator.unregister<EventBus>();
    }
  });

  Widget wrap() {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: dsTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: StackRouterScope(
        controller: router,
        stateHash: 0,
        child: const EditProfilePage(),
      ),
    );
  }

  group('EditProfilePage', () {
    testWidgets('shows DSLoader while loading', (tester) async {
      // Hold the getMe call so the loading state stays visible.
      final completer = Completer<MeProfile>();
      when(() => mockMe.getMe()).thenAnswer((_) => completer.future);

      await tester.pumpWidget(wrap());
      await tester.pump(); // trigger build (still loading)

      expect(find.byType(DSLoader), findsOneWidget);
    });

    testWidgets('shows form fields after load completes', (tester) async {
      when(() => mockMe.getMe()).thenAnswer((_) async => _kMe);

      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle(); // wait for initState Future

      expect(find.byType(DSLoader), findsNothing);
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('prefills first name and last name from profile', (
      tester,
    ) async {
      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsWidgets);
      expect(find.text('Smith'), findsWidgets);
    });

    testWidgets('loads address when hasAddress is true', (tester) async {
      when(() => mockMe.getMe()).thenAnswer((_) async => _kMeWithAddress);
      when(
        () => mockMe.getAddresses(),
      ).thenAnswer((_) async => <Address>[_kAddress]);

      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      expect(find.text('123 Main St, Dubai, Dubai'), findsOneWidget);
    });

    testWidgets('back button pops router when form is clean', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pump();

      verify(() => router.maybePop<Object?>()).called(1);
    });

    testWidgets('back button shows discard dialog when form is dirty', (
      tester,
    ) async {
      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      // Dirty the first name field
      await tester.enterText(find.byType(TextField).first, 'ChangedName');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('discard dialog keep editing keeps user on page', (
      tester,
    ) async {
      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'ChangedName');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();

      // Tap "keep editing" (first text button)
      await tester.tap(find.byType(TextButton).first);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      // Not popped
      verifyNever(() => router.maybePop<Object?>());
    });

    testWidgets('discard dialog confirm pops router', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'ChangedName');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();

      // Tap "discard" (last text button)
      await tester.tap(find.byType(TextButton).last);
      await tester.pumpAndSettle();

      verify(() => router.maybePop<Object?>()).called(1);
    });

    testWidgets('save button is disabled when required fields are empty', (
      tester,
    ) async {
      when(
        () => mockMe.getMe(),
      ).thenAnswer((_) async => const MeProfile(id: 'u1'));

      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      // Save button should be disabled (no name or address)
      final saveButton = find.byType(ElevatedButton);
      if (saveButton.evaluate().isNotEmpty) {
        final button = tester.widget<ElevatedButton>(saveButton.first);
        expect(button.onPressed, isNull);
      }
    });

    testWidgets('save succeeds when required fields are filled', (
      tester,
    ) async {
      when(
        () => mockMe.getMe(),
      ).thenAnswer((_) async => const MeProfile(id: 'u1'));

      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      final fields = find.byType(TextField);
      // Enter first name
      await tester.enterText(fields.at(0), 'Bob');
      await tester.pump();
      // Enter last name
      await tester.enterText(fields.at(1), 'Jones');
      await tester.pump();
      // Enter address
      await tester.enterText(fields.at(2), 'Marina, Dubai');
      await tester.pump();

      // Tap save
      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pumpAndSettle();

      verify(
        () => mockMe.updateProfile(
          firstName: 'Bob',
          lastName: 'Jones',
          bio: any(named: 'bio'),
        ),
      ).called(1);
    });

    testWidgets('save shows error snackbar on failure', (tester) async {
      when(
        () => mockMe.getMe(),
      ).thenAnswer((_) async => const MeProfile(id: 'u1'));
      when(
        () => mockMe.updateProfile(
          firstName: any(named: 'firstName'),
          lastName: any(named: 'lastName'),
          bio: any(named: 'bio'),
        ),
      ).thenThrow(Exception('server error'));

      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'Bob');
      await tester.pump();
      await tester.enterText(fields.at(1), 'Jones');
      await tester.pump();
      await tester.enterText(fields.at(2), 'Marina');
      await tester.pump();

      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
