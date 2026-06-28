import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/me/entity/connect_status.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:klozy/src/feature/settings/presentation/screen/seller_verification_page.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../support/ds_harness.dart';

class _MockMeRepository extends Mock implements MeRepository {}

class _MockStackRouter extends Mock implements StackRouter {}

void main() {
  setUpAll(disableDsFonts);

  late _MockMeRepository mockMe;
  late _MockStackRouter router;

  setUp(() {
    mockMe = _MockMeRepository();
    router = _MockStackRouter();

    when(() => router.maybePop<Object?>()).thenAnswer((_) async => true);

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

  Widget wrap() {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: dsTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: StackRouterScope(
        controller: router,
        stateHash: 0,
        child: const SellerVerificationPage(),
      ),
    );
  }

  group('SellerVerificationPage', () {
    testWidgets('shows DSLoader while loading', (tester) async {
      final completer = Completer<ConnectStatus>();
      when(() => mockMe.getConnectStatus()).thenAnswer((_) => completer.future);

      await tester.pumpWidget(wrap());
      await tester.pump();

      expect(find.byType(DSLoader), findsOneWidget);
    });

    testWidgets('shows notStarted status after load', (tester) async {
      when(() => mockMe.getConnectStatus()).thenAnswer(
        (_) async =>
            const ConnectStatus(onboarding: ConnectOnboarding.notStarted),
      );

      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      expect(find.byType(DSLoader), findsNothing);
      // Button visible (not complete)
      expect(find.byType(DSButtonElevated), findsOneWidget);
    });

    testWidgets('shows pending status after load', (tester) async {
      when(() => mockMe.getConnectStatus()).thenAnswer(
        (_) async => const ConnectStatus(onboarding: ConnectOnboarding.pending),
      );

      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      expect(find.byType(DSLoader), findsNothing);
      expect(find.byType(DSButtonElevated), findsOneWidget);
    });

    testWidgets('shows complete status and no button', (tester) async {
      when(() => mockMe.getConnectStatus()).thenAnswer(
        (_) async => const ConnectStatus(
          onboarding: ConnectOnboarding.complete,
          detailsSubmitted: true,
          chargesEnabled: true,
          payoutsEnabled: true,
        ),
      );

      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      expect(find.byType(DSButtonElevated), findsNothing);
    });

    testWidgets('shows CheckRow items when loaded', (tester) async {
      when(() => mockMe.getConnectStatus()).thenAnswer(
        (_) async => const ConnectStatus(
          onboarding: ConnectOnboarding.pending,
          detailsSubmitted: true,
          chargesEnabled: false,
          payoutsEnabled: false,
        ),
      );

      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      // Check circle icons (done) and radio button icons (not done)
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_unchecked), findsNWidgets(2));
    });

    testWidgets('back button calls router.maybePop', (tester) async {
      when(
        () => mockMe.getConnectStatus(),
      ).thenAnswer((_) async => const ConnectStatus());

      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pump();

      verify(() => router.maybePop<Object?>()).called(1);
    });

    testWidgets('gracefully handles getConnectStatus error', (tester) async {
      when(() => mockMe.getConnectStatus()).thenThrow(Exception('network'));

      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      // Should show default (notStarted) state without crashing
      expect(find.byType(DSLoader), findsNothing);
    });

    testWidgets('open KYB button triggers createKybLink', (tester) async {
      when(() => mockMe.getConnectStatus()).thenAnswer(
        (_) async =>
            const ConnectStatus(onboarding: ConnectOnboarding.notStarted),
      );
      when(
        () => mockMe.createKybLink(),
      ).thenAnswer((_) async => 'https://connect.stripe.com/setup/e/abc');

      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DSButtonElevated));
      // launchUrl never returns in the test environment; use pump() to process
      // the createKybLink microtask without waiting for the URL launch to settle.
      await tester.pump();
      await tester.pump();

      verify(() => mockMe.createKybLink()).called(1);
    });

    testWidgets('open KYB shows snackbar when link is null', (tester) async {
      when(() => mockMe.getConnectStatus()).thenAnswer(
        (_) async =>
            const ConnectStatus(onboarding: ConnectOnboarding.notStarted),
      );
      when(() => mockMe.createKybLink()).thenAnswer((_) async => null);

      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DSButtonElevated));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('open KYB shows snackbar on exception', (tester) async {
      when(() => mockMe.getConnectStatus()).thenAnswer(
        (_) async =>
            const ConnectStatus(onboarding: ConnectOnboarding.notStarted),
      );
      when(() => mockMe.createKybLink()).thenThrow(Exception('error'));

      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DSButtonElevated));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
