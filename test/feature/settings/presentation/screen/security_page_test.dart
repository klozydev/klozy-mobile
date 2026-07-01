import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/settings/presentation/screen/security_page.dart';
import 'package:klozy/src/router/app_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../support/ds_harness.dart';

class _MockStackRouter extends Mock implements StackRouter {}

void main() {
  setUpAll(() {
    disableDsFonts();
    registerFallbackValue(const ChangeEmailRoute());
    registerFallbackValue(const ChangePasswordRoute());
    registerFallbackValue(const ChangePhoneRoute());
  });

  late _MockStackRouter router;

  setUp(() {
    router = _MockStackRouter();
    when(() => router.maybePop<Object?>()).thenAnswer((_) async => true);
    when(
      () => router.push<Object?>(any(), onFailure: any(named: 'onFailure')),
    ).thenAnswer((_) async => null);
  });

  Widget pump() {
    return dsWrapRouted(const SecurityPage(), router: router);
  }

  group('SecurityPage — layout', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(pump());
      await tester.pump();
      expect(find.byType(SecurityPage), findsOneWidget);
    });
  });

  group('SecurityPage — navigation', () {
    testWidgets('change email row pushes ChangeEmailRoute', (tester) async {
      await tester.pumpWidget(pump());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.mail_outline_rounded));
      await tester.pump();

      final captured = verify(
        () => router.push<Object?>(
          captureAny(),
          onFailure: any(named: 'onFailure'),
        ),
      ).captured;
      expect(captured.single, isA<ChangeEmailRoute>());
    });

    testWidgets('change password row pushes ChangePasswordRoute', (
      tester,
    ) async {
      await tester.pumpWidget(pump());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.lock_outline_rounded));
      await tester.pump();

      final captured = verify(
        () => router.push<Object?>(
          captureAny(),
          onFailure: any(named: 'onFailure'),
        ),
      ).captured;
      expect(captured.single, isA<ChangePasswordRoute>());
    });

    testWidgets('phone number row pushes ChangePhoneRoute', (tester) async {
      await tester.pumpWidget(pump());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.phone_outlined));
      await tester.pump();

      final captured = verify(
        () => router.push<Object?>(
          captureAny(),
          onFailure: any(named: 'onFailure'),
        ),
      ).captured;
      expect(captured.single, isA<ChangePhoneRoute>());
    });

    testWidgets('back button calls router.maybePop', (tester) async {
      await tester.pumpWidget(pump());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      verify(() => router.maybePop<Object?>()).called(1);
    });
  });
}
