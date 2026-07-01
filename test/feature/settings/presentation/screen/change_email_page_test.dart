import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/auth/auth_exception.dart';
import 'package:klozy/src/domain/auth/auth_repository.dart';
import 'package:klozy/src/domain/auth/entity/auth_user.dart';
import 'package:klozy/src/feature/settings/presentation/screen/change_email_page.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../support/ds_harness.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockStackRouter extends Mock implements StackRouter {}

const _kUser = AuthUser(uid: 'u1', email: 'old@example.com');

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
    return dsWrapRouted(const ChangeEmailPage(), router: router);
  }

  group('ChangeEmailPage — current email card', () {
    testWidgets('shows current email when user has email', (tester) async {
      when(() => mockAuth.currentUser).thenReturn(_kUser);
      await tester.pumpWidget(pump());
      await tester.pump();
      expect(find.text('old@example.com'), findsOneWidget);
    });

    testWidgets('does not show email card when currentUser is null', (
      tester,
    ) async {
      when(() => mockAuth.currentUser).thenReturn(null);
      await tester.pumpWidget(pump());
      await tester.pump();
      expect(find.text('old@example.com'), findsNothing);
    });

    testWidgets('does not show email card when email is empty', (tester) async {
      when(
        () => mockAuth.currentUser,
      ).thenReturn(const AuthUser(uid: 'u2', email: ''));
      await tester.pumpWidget(pump());
      await tester.pump();
      expect(find.text('old@example.com'), findsNothing);
    });
  });

  group('ChangeEmailPage — form validation', () {
    testWidgets('save button disabled when field is empty', (tester) async {
      when(() => mockAuth.currentUser).thenReturn(null);
      await tester.pumpWidget(pump());
      await tester.pump();

      final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(btn.onPressed, isNull);
    });

    testWidgets('shows error text for invalid email', (tester) async {
      when(() => mockAuth.currentUser).thenReturn(null);
      await tester.pumpWidget(pump());
      await tester.pump();

      await tester.enterText(find.byType(TextField).first, 'notanemail');
      await tester.pump();

      // l10n: auth_email_invalid = "Enter a valid email address"
      expect(find.textContaining('valid email'), findsAny);
    });

    testWidgets('save button enabled for valid email', (tester) async {
      when(() => mockAuth.currentUser).thenReturn(null);
      await tester.pumpWidget(pump());
      await tester.pump();

      await tester.enterText(find.byType(TextField).first, 'new@example.com');
      await tester.pump();

      final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(btn.onPressed, isNotNull);
    });

    testWidgets('no error text when field is empty', (tester) async {
      when(() => mockAuth.currentUser).thenReturn(null);
      await tester.pumpWidget(pump());
      await tester.pump();

      // field is empty — no error should be shown
      expect(find.textContaining('invalid'), findsNothing);
    });
  });

  group('ChangeEmailPage — save flow', () {
    testWidgets('successful save calls sendEmailUpdateVerification and pops', (
      tester,
    ) async {
      when(() => mockAuth.currentUser).thenReturn(null);
      when(
        () => mockAuth.sendEmailUpdateVerification(any()),
      ).thenAnswer((_) async {});
      await tester.pumpWidget(pump());
      await tester.pump();

      await tester.enterText(find.byType(TextField).first, 'new@example.com');
      await tester.pump();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      verify(
        () => mockAuth.sendEmailUpdateVerification('new@example.com'),
      ).called(1);
      verify(() => router.maybePop<Object?>()).called(1);
    });

    testWidgets('AuthException shows the exception message in snackbar', (
      tester,
    ) async {
      when(() => mockAuth.currentUser).thenReturn(null);
      when(
        () => mockAuth.sendEmailUpdateVerification(any()),
      ).thenThrow(const AuthException('Reauthentication required'));
      await tester.pumpWidget(pump());
      await tester.pump();

      await tester.enterText(find.byType(TextField).first, 'new@example.com');
      await tester.pump();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Reauthentication required'), findsOneWidget);
      verifyNever(() => router.maybePop<Object?>());
    });

    testWidgets('generic exception shows settings_save_failed snackbar', (
      tester,
    ) async {
      when(() => mockAuth.currentUser).thenReturn(null);
      when(
        () => mockAuth.sendEmailUpdateVerification(any()),
      ).thenThrow(Exception('network'));
      await tester.pumpWidget(pump());
      await tester.pump();

      await tester.enterText(find.byType(TextField).first, 'new@example.com');
      await tester.pump();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // l10n: settings_save_failed — at least the snackbar is shown
      expect(find.byType(SnackBar), findsOneWidget);
      verifyNever(() => router.maybePop<Object?>());
    });
  });

  group('ChangeEmailPage — navigation', () {
    testWidgets('back button calls router.maybePop', (tester) async {
      when(() => mockAuth.currentUser).thenReturn(null);
      await tester.pumpWidget(pump());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      verify(() => router.maybePop<Object?>()).called(1);
    });
  });
}
