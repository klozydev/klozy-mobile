import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/me/entity/me_profile.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:klozy/src/feature/settings/presentation/screen/payout_page.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../support/ds_harness.dart';

class _MockMeRepository extends Mock implements MeRepository {}

class _MockStackRouter extends Mock implements StackRouter {}

const _kMeNoIban = MeProfile(id: 'u1');
const _kMeWithIban = MeProfile(id: 'u1', payoutIbanMasked: 'AE** **** 1234');

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

  Widget _pump() {
    return dsWrapRouted(const PayoutPage(), router: router);
  }

  group('PayoutPage — current IBAN display', () {
    testWidgets('shows masked IBAN when user has one', (tester) async {
      when(() => mockMe.getMe()).thenAnswer((_) async => _kMeWithIban);
      await tester.pumpWidget(_pump());
      await tester.pumpAndSettle();

      expect(find.textContaining('AE** **** 1234'), findsOneWidget);
    });

    testWidgets('does not show masked IBAN when user has none', (tester) async {
      when(() => mockMe.getMe()).thenAnswer((_) async => _kMeNoIban);
      await tester.pumpWidget(_pump());
      await tester.pumpAndSettle();

      expect(find.textContaining('AE** **** 1234'), findsNothing);
    });

    testWidgets('gracefully handles getMe error in initState', (tester) async {
      // Use Future.error so the async error goes through .ignore() in initState
      // rather than throwing synchronously during build.
      when(
        () => mockMe.getMe(),
      ).thenAnswer((_) => Future.error(Exception('network')));
      await tester.pumpWidget(_pump());
      await tester.pumpAndSettle();
      // Page still renders, just no masked IBAN
      expect(find.byType(PayoutPage), findsOneWidget);
    });
  });

  group('PayoutPage — IBAN validation', () {
    testWidgets('save button disabled with empty field', (tester) async {
      when(() => mockMe.getMe()).thenAnswer((_) async => _kMeNoIban);
      await tester.pumpWidget(_pump());
      await tester.pumpAndSettle();

      final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(btn.onPressed, isNull);
    });

    testWidgets('shows error for invalid IBAN', (tester) async {
      when(() => mockMe.getMe()).thenAnswer((_) async => _kMeNoIban);
      await tester.pumpWidget(_pump());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'GB12345');
      await tester.pump();

      // l10n: settings_iban_invalid = "Enter a valid UAE IBAN (starts with AE)"
      expect(find.textContaining('valid UAE'), findsAny);
    });

    testWidgets('save button enabled with valid UAE IBAN', (tester) async {
      when(() => mockMe.getMe()).thenAnswer((_) async => _kMeNoIban);
      await tester.pumpWidget(_pump());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField).first,
        'AE070331234567890123456',
      );
      await tester.pump();

      final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(btn.onPressed, isNotNull);
    });

    testWidgets('no error text when field is empty', (tester) async {
      when(() => mockMe.getMe()).thenAnswer((_) async => _kMeNoIban);
      await tester.pumpWidget(_pump());
      await tester.pumpAndSettle();

      expect(find.textContaining('invalid'), findsNothing);
    });
  });

  group('PayoutPage — save flow', () {
    testWidgets('successful save calls setPayoutIban and pops', (tester) async {
      when(() => mockMe.getMe()).thenAnswer((_) async => _kMeNoIban);
      when(() => mockMe.setPayoutIban(any())).thenAnswer((_) async {});

      await tester.pumpWidget(_pump());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField).first,
        'AE070331234567890123456',
      );
      await tester.pump();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      verify(() => mockMe.setPayoutIban('AE070331234567890123456')).called(1);
      verify(() => router.maybePop<Object?>()).called(1);
    });

    testWidgets('error shows snackbar without pop', (tester) async {
      when(() => mockMe.getMe()).thenAnswer((_) async => _kMeNoIban);
      when(() => mockMe.setPayoutIban(any())).thenThrow(Exception('server'));

      await tester.pumpWidget(_pump());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField).first,
        'AE070331234567890123456',
      );
      await tester.pump();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      verifyNever(() => router.maybePop<Object?>());
    });
  });

  group('PayoutPage — navigation', () {
    testWidgets('back button calls router.maybePop', (tester) async {
      when(() => mockMe.getMe()).thenAnswer((_) async => _kMeNoIban);
      await tester.pumpWidget(_pump());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      verify(() => router.maybePop<Object?>()).called(1);
    });
  });
}
