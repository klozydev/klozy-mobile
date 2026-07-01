import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/sell/presentation/widget/sell_success_widget.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../support/ds_harness.dart';

class _MockStackRouter extends Mock implements StackRouter {}

// ignore: avoid_implementing_value_types
class _FakeRoute extends Fake implements PageRouteInfo<Object?> {}

void main() {
  late _MockStackRouter router;

  setUpAll(() {
    disableDsFonts();
    registerFallbackValue(_FakeRoute());
  });

  setUp(() {
    router = _MockStackRouter();
    when(() => router.replace(any())).thenAnswer((_) async => null);
    when(() => router.maybePop<Object?>()).thenAnswer((_) async => true);
  });

  Widget buildWidget({String productId = 'prod-123'}) {
    return dsWrapRouted(
      SellSuccessWidget(productId: productId),
      router: router,
    );
  }

  testWidgets('renders check icon', (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pump();

    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });

  testWidgets('renders "view listing" button', (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pump();

    expect(find.byType(ElevatedButton), findsAtLeastNWidgets(1));
  });

  testWidgets('view listing taps router.replace', (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pump();

    // The first DSButtonElevated is the "view listing" button.
    await tester.tap(find.byType(ElevatedButton).first);
    await tester.pump();

    verify(() => router.replace(any())).called(1);
  });

  testWidgets('create reel and back to home outline buttons exist', (
    tester,
  ) async {
    await tester.pumpWidget(buildWidget());
    await tester.pump();

    expect(find.byType(OutlinedButton), findsAtLeastNWidgets(2));
  });

  testWidgets('back to home calls router.maybePop', (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pump();

    // Last OutlinedButton is "Back to home".
    await tester.tap(find.byType(OutlinedButton).last);
    await tester.pump();

    verify(() => router.maybePop<Object?>()).called(1);
  });

  testWidgets('view listing disabled when productId empty', (tester) async {
    await tester.pumpWidget(buildWidget(productId: ''));
    await tester.pump();

    // Tapping a disabled button should not invoke router.replace.
    await tester.tap(find.byType(ElevatedButton).first, warnIfMissed: false);
    await tester.pump();

    verifyNever(() => router.replace(any()));
  });

  testWidgets('create reel taps router.replace', (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pump();

    // First OutlinedButton is "Create reel".
    await tester.tap(find.byType(OutlinedButton).first);
    await tester.pump();

    verify(() => router.replace(any())).called(1);
  });
}
