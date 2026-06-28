import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/auth/auth_exception.dart';
import 'package:klozy/src/domain/auth/auth_repository.dart';
import 'package:klozy/src/domain/auth/entity/auth_user.dart';
import 'package:klozy/src/feature/settings/presentation/screen/change_phone_page.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../support/ds_harness.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockStackRouter extends Mock implements StackRouter {}

void main() {
  setUpAll(disableDsFonts);

  late _MockAuthRepository mockAuth;
  late _MockStackRouter router;

  setUp(() {
    mockAuth = _MockAuthRepository();
    router = _MockStackRouter();

    when(() => mockAuth.currentUser).thenReturn(null);
    when(() => mockAuth.startPhoneVerification(any())).thenAnswer(
      (_) async =>
          const PhoneVerification(verificationId: 'vid-123', resendToken: 1),
    );
    when(
      () => mockAuth.updatePhoneNumber(
        verificationId: any(named: 'verificationId'),
        smsCode: any(named: 'smsCode'),
      ),
    ).thenAnswer((_) async {});

    when(() => router.maybePop<Object?>()).thenAnswer((_) async => true);

    if (locator.isRegistered<AuthRepository>()) {
      locator.unregister<AuthRepository>();
    }
    locator.registerSingleton<AuthRepository>(mockAuth);
  });

  tearDown(() {
    if (locator.isRegistered<AuthRepository>()) {
      locator.unregister<AuthRepository>();
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
        child: const ChangePhonePage(),
      ),
    );
  }

  group('ChangePhonePage', () {
    testWidgets('renders number step initially', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(DSButtonElevated), findsOneWidget);
    });

    testWidgets('shows current phone number when user has one', (tester) async {
      when(
        () => mockAuth.currentUser,
      ).thenReturn(const AuthUser(uid: 'u1', phoneNumber: '+1234567890'));

      await tester.pumpWidget(wrap());
      await tester.pump();

      expect(find.text('+1234567890'), findsOneWidget);
    });

    testWidgets('does not show current number when user has none', (
      tester,
    ) async {
      when(() => mockAuth.currentUser).thenReturn(null);

      await tester.pumpWidget(wrap());
      await tester.pump();

      // No phone number container
      expect(find.text('+1234567890'), findsNothing);
    });

    testWidgets('send code button disabled when number too short', (
      tester,
    ) async {
      await tester.pumpWidget(wrap());
      await tester.pump();

      // Short number – should not enable button
      await tester.enterText(find.byType(TextField), '+1');
      await tester.pump();

      // DSButtonElevated wraps ElevatedButton; check onPressed == null when disabled.
      final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(btn.onPressed, isNull);
    });

    testWidgets('send code button enabled with valid number', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pump();

      await tester.enterText(find.byType(TextField), '+12345678901');
      await tester.pump();

      final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(btn.onPressed, isNotNull);
    });

    testWidgets('back button calls router.maybePop on number step', (
      tester,
    ) async {
      await tester.pumpWidget(wrap());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pump();

      verify(() => router.maybePop<Object?>()).called(1);
    });

    testWidgets('tapping send code transitions to code step', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pump();

      await tester.enterText(find.byType(TextField), '+12345678901');
      await tester.pump();

      await tester.tap(find.byType(DSButtonElevated));
      await tester.pumpAndSettle();

      // The code step has a DSCodeInput (multiple text fields for 6-digit code)
      final textFields = find.byType(TextField);
      expect(textFields.evaluate().length, greaterThan(1));
    });

    testWidgets('back button on code step resets to number step', (
      tester,
    ) async {
      await tester.pumpWidget(wrap());
      await tester.pump();

      // Enter number and send code
      await tester.enterText(find.byType(TextField), '+12345678901');
      await tester.pump();
      await tester.tap(find.byType(DSButtonElevated));
      await tester.pumpAndSettle();

      // Now on code step – tap back
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pump();

      // Should NOT pop router (goes back to number step)
      verifyNever(() => router.maybePop<Object?>());
      // Back to number step: single TextField
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('send code failure shows snackbar', (tester) async {
      when(
        () => mockAuth.startPhoneVerification(any()),
      ).thenThrow(Exception('firebase error'));

      await tester.pumpWidget(wrap());
      await tester.pump();

      await tester.enterText(find.byType(TextField), '+12345678901');
      await tester.pump();
      await tester.tap(find.byType(DSButtonElevated));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('send code AuthException shows error message', (tester) async {
      when(
        () => mockAuth.startPhoneVerification(any()),
      ).thenThrow(const AuthException('invalid phone'));

      await tester.pumpWidget(wrap());
      await tester.pump();

      await tester.enterText(find.byType(TextField), '+12345678901');
      await tester.pump();
      await tester.tap(find.byType(DSButtonElevated));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('invalid phone'), findsOneWidget);
    });
  });

  group('ChangePhonePage — verify flow', () {
    /// Helper: navigates to the code step (enters a valid phone, sends code).
    Future<void> _goToCodeStep(WidgetTester tester) async {
      await tester.pumpWidget(wrap());
      await tester.pump();

      await tester.enterText(find.byType(TextField), '+12345678901');
      await tester.pump();
      await tester.tap(find.byType(DSButtonElevated));
      await tester.pumpAndSettle();
    }

    /// Enters a 6-digit code into the DSCodeInput fields (all 6 TextFields).
    Future<void> _enterCode(WidgetTester tester, String code) async {
      final fields = find.byType(TextField);
      for (int i = 0; i < 6; i++) {
        await tester.enterText(fields.at(i), code[i]);
        await tester.pump();
      }
    }

    testWidgets('successful verify calls updatePhoneNumber and pops', (
      tester,
    ) async {
      await _goToCodeStep(tester);
      await _enterCode(tester, '123456');

      await tester.tap(find.byType(DSButtonElevated));
      await tester.pumpAndSettle();

      verify(
        () => mockAuth.updatePhoneNumber(
          verificationId: 'vid-123',
          smsCode: '123456',
        ),
      ).called(1);
      verify(() => router.maybePop<Object?>()).called(1);
    });

    testWidgets('verify AuthException shows error message', (tester) async {
      when(
        () => mockAuth.updatePhoneNumber(
          verificationId: any(named: 'verificationId'),
          smsCode: any(named: 'smsCode'),
        ),
      ).thenThrow(const AuthException('wrong code'));

      await _goToCodeStep(tester);
      await _enterCode(tester, '999999');

      await tester.tap(find.byType(DSButtonElevated));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('wrong code'), findsOneWidget);
      verifyNever(() => router.maybePop<Object?>());
    });

    testWidgets('verify generic error shows save-failed snackbar', (
      tester,
    ) async {
      when(
        () => mockAuth.updatePhoneNumber(
          verificationId: any(named: 'verificationId'),
          smsCode: any(named: 'smsCode'),
        ),
      ).thenThrow(Exception('network'));

      await _goToCodeStep(tester);
      await _enterCode(tester, '000000');

      await tester.tap(find.byType(DSButtonElevated));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      verifyNever(() => router.maybePop<Object?>());
    });
  });
}
