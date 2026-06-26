import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/core/account/account_gate_sheet.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_button_outline.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/domain/account/entity/account_status.dart';
import 'package:klozy/src/router/app_router.dart';
import 'package:mocktail/mocktail.dart';

class _MockStackRouter extends Mock implements StackRouter {}

/// Wraps [child] in the minimal material/localization tree plus a stubbed
/// [StackRouterScope] so that `context.router.push(...)` calls in button
/// callbacks do not throw in tests.
Widget _wrap(Widget child, {required StackRouter router}) {
  return MaterialApp(
    theme: dsTheme(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: StackRouterScope(
        controller: router,
        stateHash: 0,
        child: Center(child: child),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    // Prevent google_fonts from hitting the network in tests; rendering without
    // Poppins fallback glyphs does not affect structural/text assertions.
    GoogleFonts.config.allowRuntimeFetching = false;
    // Register the fallback for PageRouteInfo subtypes used in push() stubs.
    registerFallbackValue(const WelcomeRoute());
    registerFallbackValue(const PersonalizeRoute());
  });

  group('AccountGateSheet — guest status', () {
    late _MockStackRouter router;

    setUp(() {
      router = _MockStackRouter();
      when(
        () => router.push<Object?>(any(), onFailure: any(named: 'onFailure')),
      ).thenAnswer((_) async => null);
    });

    testWidgets('renders title and subtitle', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(
          const AccountGateSheet(status: AccountStatus.guest),
          router: router,
        ),
      );
      await tester.pump();

      expect(
        find.text('Create an account or log in to continue'),
        findsOneWidget,
      );
      expect(
        find.text(
          'Join Klozy to wishlist items, follow sellers and buy pre-loved fashion.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows DSButtonElevated and DSButtonOutline', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const AccountGateSheet(status: AccountStatus.guest),
          router: router,
        ),
      );
      await tester.pump();

      expect(find.byType(DSButtonElevated), findsOneWidget);
      expect(find.byType(DSButtonOutline), findsOneWidget);
    });

    testWidgets('tapping "Create an account" pushes WelcomeRoute', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const AccountGateSheet(status: AccountStatus.guest),
          router: router,
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Create an account'));
      await tester.pump();

      final captured = verify(
        () => router.push<Object?>(
          captureAny(),
          onFailure: any(named: 'onFailure'),
        ),
      ).captured;
      expect(captured.single, isA<WelcomeRoute>());
    });

    testWidgets('tapping "Log in" pushes WelcomeRoute', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const AccountGateSheet(status: AccountStatus.guest),
          router: router,
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Log in'));
      await tester.pump();

      final captured = verify(
        () => router.push<Object?>(
          captureAny(),
          onFailure: any(named: 'onFailure'),
        ),
      ).captured;
      expect(captured.single, isA<WelcomeRoute>());
    });
  });

  group('AccountGateSheet — legacy status', () {
    late _MockStackRouter router;

    setUp(() {
      router = _MockStackRouter();
      when(
        () => router.push<Object?>(any(), onFailure: any(named: 'onFailure')),
      ).thenAnswer((_) async => null);
    });

    testWidgets('renders same guest/legacy copy', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(
          const AccountGateSheet(status: AccountStatus.legacy),
          router: router,
        ),
      );
      await tester.pump();

      expect(
        find.text('Create an account or log in to continue'),
        findsOneWidget,
      );
    });

    testWidgets('shows DSButtonElevated and DSButtonOutline', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const AccountGateSheet(status: AccountStatus.legacy),
          router: router,
        ),
      );
      await tester.pump();

      expect(find.byType(DSButtonElevated), findsOneWidget);
      expect(find.byType(DSButtonOutline), findsOneWidget);
    });

    testWidgets('tapping "Create an account" pushes WelcomeRoute', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const AccountGateSheet(status: AccountStatus.legacy),
          router: router,
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Create an account'));
      await tester.pump();

      final captured = verify(
        () => router.push<Object?>(
          captureAny(),
          onFailure: any(named: 'onFailure'),
        ),
      ).captured;
      expect(captured.single, isA<WelcomeRoute>());
    });
  });

  group('AccountGateSheet — incompleteOnboarding status', () {
    late _MockStackRouter router;

    setUp(() {
      router = _MockStackRouter();
      when(
        () => router.push<Object?>(any(), onFailure: any(named: 'onFailure')),
      ).thenAnswer((_) async => null);
    });

    testWidgets('renders title and subtitle', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(
          const AccountGateSheet(status: AccountStatus.incompleteOnboarding),
          router: router,
        ),
      );
      await tester.pump();

      expect(find.text('Finish setting up your profile'), findsOneWidget);
      expect(
        find.text('Complete your profile to unlock all Klozy features.'),
        findsOneWidget,
      );
    });

    testWidgets('shows only DSButtonElevated — no DSButtonOutline', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const AccountGateSheet(status: AccountStatus.incompleteOnboarding),
          router: router,
        ),
      );
      await tester.pump();

      expect(find.byType(DSButtonElevated), findsOneWidget);
      expect(find.byType(DSButtonOutline), findsNothing);
    });

    testWidgets('tapping "Finish setup" pushes ProfileCompletionRoute', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const AccountGateSheet(status: AccountStatus.incompleteOnboarding),
          router: router,
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Finish setup'));
      await tester.pump();

      final captured = verify(
        () => router.push<Object?>(
          captureAny(),
          onFailure: any(named: 'onFailure'),
        ),
      ).captured;
      // The gate skips the "personalize your feed" step and goes straight to
      // the profile-completion form.
      expect(captured.single, isA<ProfileCompletionRoute>());
    });
  });
}
