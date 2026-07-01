import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/settings/presentation/screen/personal_data_page.dart';
import 'package:klozy/src/router/app_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../support/ds_harness.dart';

class _MockStackRouter extends Mock implements StackRouter {}

void main() {
  setUpAll(() {
    disableDsFonts();
    registerFallbackValue(const EditProfileRoute());
    registerFallbackValue(const ClothingPreferenceRoute());
    registerFallbackValue(const PreferredSizeRoute());
    registerFallbackValue(const PreferredBrandsRoute());
    registerFallbackValue(const BlockedUsersRoute());
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
    return dsWrapRouted(const PersonalDataPage(), router: router);
  }

  group('PersonalDataPage — layout', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(pump());
      await tester.pump();
      expect(find.byType(PersonalDataPage), findsOneWidget);
    });
  });

  group('PersonalDataPage — navigation', () {
    testWidgets('personal information row pushes EditProfileRoute', (
      tester,
    ) async {
      await tester.pumpWidget(pump());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.person_outline));
      await tester.pump();

      final captured = verify(
        () => router.push<Object?>(
          captureAny(),
          onFailure: any(named: 'onFailure'),
        ),
      ).captured;
      expect(captured.single, isA<EditProfileRoute>());
    });

    testWidgets('clothing preference row pushes ClothingPreferenceRoute', (
      tester,
    ) async {
      await tester.pumpWidget(pump());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.palette_outlined));
      await tester.pump();

      final captured = verify(
        () => router.push<Object?>(
          captureAny(),
          onFailure: any(named: 'onFailure'),
        ),
      ).captured;
      expect(captured.single, isA<ClothingPreferenceRoute>());
    });

    testWidgets('preferred size row pushes PreferredSizeRoute', (tester) async {
      await tester.pumpWidget(pump());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.straighten_rounded));
      await tester.pump();

      final captured = verify(
        () => router.push<Object?>(
          captureAny(),
          onFailure: any(named: 'onFailure'),
        ),
      ).captured;
      expect(captured.single, isA<PreferredSizeRoute>());
    });

    testWidgets('preferred brands row pushes PreferredBrandsRoute', (
      tester,
    ) async {
      await tester.pumpWidget(pump());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.sell_outlined));
      await tester.pump();

      final captured = verify(
        () => router.push<Object?>(
          captureAny(),
          onFailure: any(named: 'onFailure'),
        ),
      ).captured;
      expect(captured.single, isA<PreferredBrandsRoute>());
    });

    testWidgets('blocked users row pushes BlockedUsersRoute', (tester) async {
      await tester.pumpWidget(pump());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.block_outlined));
      await tester.pump();

      final captured = verify(
        () => router.push<Object?>(
          captureAny(),
          onFailure: any(named: 'onFailure'),
        ),
      ).captured;
      expect(captured.single, isA<BlockedUsersRoute>());
    });

    testWidgets('back button calls router.maybePop', (tester) async {
      await tester.pumpWidget(pump());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      verify(() => router.maybePop<Object?>()).called(1);
    });
  });
}
