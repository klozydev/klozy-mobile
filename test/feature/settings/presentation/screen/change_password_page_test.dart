import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/auth/auth_exception.dart';
import 'package:klozy/src/domain/auth/auth_repository.dart';
import 'package:klozy/src/feature/settings/presentation/screen/change_password_page.dart';
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

  Widget pump() {
    return dsWrapRouted(const ChangePasswordPage(), router: router);
  }

  // Local helper functions to find the two password TextFields.
  Finder passwordField() => find.byType(TextField).at(0);
  Finder confirmField() => find.byType(TextField).at(1);

  group('ChangePasswordPage — initial state', () {
    testWidgets('save button disabled when fields are empty', (tester) async {
      await tester.pumpWidget(pump());
      await tester.pump();

      final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(btn.onPressed, isNull);
    });
  });

  group('ChangePasswordPage — validation', () {
    testWidgets('shows too-short error when password < 8 chars', (
      tester,
    ) async {
      await tester.pumpWidget(pump());
      await tester.pump();

      await tester.enterText(passwordField(), 'short');
      await tester.pump();

      expect(find.textContaining('short'), findsAny);
    });

    testWidgets('shows mismatch error when confirm differs', (tester) async {
      await tester.pumpWidget(pump());
      await tester.pump();

      await tester.enterText(passwordField(), 'longpassword');
      await tester.enterText(confirmField(), 'different123');
      await tester.pump();

      expect(find.textContaining('match'), findsAny);
    });

    testWidgets('no error and button enabled with matching long passwords', (
      tester,
    ) async {
      await tester.pumpWidget(pump());
      await tester.pump();

      await tester.enterText(passwordField(), 'ValidPass1');
      await tester.enterText(confirmField(), 'ValidPass1');
      await tester.pump();

      final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(btn.onPressed, isNotNull);
    });

    testWidgets(
      'button disabled when confirm is empty even with valid password',
      (tester) async {
        await tester.pumpWidget(pump());
        await tester.pump();

        await tester.enterText(passwordField(), 'ValidPass1');
        await tester.pump();

        final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(btn.onPressed, isNull);
      },
    );
  });

  group('ChangePasswordPage — save flow', () {
    testWidgets('successful save calls updatePassword and pops', (
      tester,
    ) async {
      when(() => mockAuth.updatePassword(any())).thenAnswer((_) async {});

      await tester.pumpWidget(pump());
      await tester.pump();

      await tester.enterText(passwordField(), 'NewPass123');
      await tester.enterText(confirmField(), 'NewPass123');
      await tester.pump();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      verify(() => mockAuth.updatePassword('NewPass123')).called(1);
      verify(() => router.maybePop<Object?>()).called(1);
    });

    testWidgets('AuthException shows message in snackbar', (tester) async {
      when(
        () => mockAuth.updatePassword(any()),
      ).thenThrow(const AuthException('Sign in again'));

      await tester.pumpWidget(pump());
      await tester.pump();

      await tester.enterText(passwordField(), 'NewPass123');
      await tester.enterText(confirmField(), 'NewPass123');
      await tester.pump();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Sign in again'), findsOneWidget);
      verifyNever(() => router.maybePop<Object?>());
    });

    testWidgets('generic exception shows snackbar without pop', (tester) async {
      when(
        () => mockAuth.updatePassword(any()),
      ).thenThrow(Exception('network'));

      await tester.pumpWidget(pump());
      await tester.pump();

      await tester.enterText(passwordField(), 'NewPass123');
      await tester.enterText(confirmField(), 'NewPass123');
      await tester.pump();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      verifyNever(() => router.maybePop<Object?>());
    });
  });

  group('ChangePasswordPage — navigation', () {
    testWidgets('back button calls router.maybePop', (tester) async {
      await tester.pumpWidget(pump());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      verify(() => router.maybePop<Object?>()).called(1);
    });
  });
}
