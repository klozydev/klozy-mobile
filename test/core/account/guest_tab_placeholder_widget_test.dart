import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/core/account/guest_tab_placeholder_widget.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_button_outline.dart';
import 'package:klozy/src/design/components/ds_klozy_mark.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/router/app_router.dart';
import 'package:mocktail/mocktail.dart';

class _MockStackRouter extends Mock implements StackRouter {}

Widget _wrap(Widget child, {required StackRouter router}) {
  return MaterialApp(
    theme: dsTheme(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: StackRouterScope(controller: router, stateHash: 0, child: child),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    registerFallbackValue(const WelcomeRoute());
  });

  group('GuestTabPlaceholderWidget', () {
    late _MockStackRouter router;

    setUp(() {
      router = _MockStackRouter();
      when(
        () => router.push<Object?>(any(), onFailure: any(named: 'onFailure')),
      ).thenAnswer((_) async => null);
    });

    testWidgets('renders Klozy mark', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(const GuestTabPlaceholderWidget(), router: router),
      );
      await tester.pump();

      expect(find.byType(DSKlozyMark), findsOneWidget);
    });

    testWidgets('renders title', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(const GuestTabPlaceholderWidget(), router: router),
      );
      await tester.pump();

      expect(find.text('Sign in to Klozy'), findsOneWidget);
    });

    testWidgets('renders subtitle', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(const GuestTabPlaceholderWidget(), router: router),
      );
      await tester.pump();

      expect(
        find.text('Create an account or log in to access this section.'),
        findsOneWidget,
      );
    });

    testWidgets('renders primary CTA and secondary log-in button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const GuestTabPlaceholderWidget(), router: router),
      );
      await tester.pump();

      expect(find.byType(DSButtonElevated), findsOneWidget);
      expect(find.byType(DSButtonOutline), findsOneWidget);
    });

    testWidgets('tapping "Create an account" pushes WelcomeRoute', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const GuestTabPlaceholderWidget(), router: router),
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
        _wrap(const GuestTabPlaceholderWidget(), router: router),
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
}
