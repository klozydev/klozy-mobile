import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/core/account/incomplete_profile_placeholder_widget.dart';
import 'package:klozy/src/design/components/ds_app_logo.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
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
    registerFallbackValue(const EditProfileRoute());
  });

  group('IncompleteProfilePlaceholderWidget', () {
    late _MockStackRouter router;

    setUp(() {
      router = _MockStackRouter();
      when(
        () => router.push<Object?>(any(), onFailure: any(named: 'onFailure')),
      ).thenAnswer((_) async => null);
    });

    testWidgets('renders app logo', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(const IncompleteProfilePlaceholderWidget(), router: router),
      );
      await tester.pump();

      expect(find.byType(DSAppLogo), findsOneWidget);
    });

    testWidgets('renders title', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(const IncompleteProfilePlaceholderWidget(), router: router),
      );
      await tester.pump();

      expect(find.text('Finish setting up your profile'), findsOneWidget);
    });

    testWidgets('renders subtitle', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(const IncompleteProfilePlaceholderWidget(), router: router),
      );
      await tester.pump();

      expect(
        find.text(
          'Complete your profile to start chatting with buyers and sellers.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders the complete-profile CTA', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const IncompleteProfilePlaceholderWidget(), router: router),
      );
      await tester.pump();

      expect(find.byType(DSButtonElevated), findsOneWidget);
      expect(find.text('Complete profile'), findsOneWidget);
    });

    testWidgets('tapping the CTA pushes EditProfileRoute', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const IncompleteProfilePlaceholderWidget(), router: router),
      );
      await tester.pump();

      await tester.tap(find.text('Complete profile'));
      await tester.pump();

      final captured = verify(
        () => router.push<Object?>(
          captureAny(),
          onFailure: any(named: 'onFailure'),
        ),
      ).captured;
      expect(captured.single, isA<EditProfileRoute>());
    });
  });
}
