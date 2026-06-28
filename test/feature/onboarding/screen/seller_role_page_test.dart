import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/design/components/ds_option_card.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/me/entity/me_profile.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:klozy/src/domain/sell/usecase/check_sell_prerequisite_usecase.dart';
import 'package:klozy/src/domain/sell/usecase/sell_prerequisite.dart';
import 'package:klozy/src/feature/onboarding/presentation/bloc/seller_role_bloc.dart';
import 'package:klozy/src/feature/onboarding/presentation/bloc/seller_role_event.dart';
import 'package:klozy/src/feature/onboarding/presentation/bloc/seller_role_state.dart';
import 'package:klozy/src/feature/onboarding/presentation/screen/seller_role_page.dart';
import 'package:klozy/src/router/app_router.dart';
import 'package:mocktail/mocktail.dart';

class _MockMeRepository extends Mock implements MeRepository {}

class _MockStackRouter extends Mock implements StackRouter {}

class _MockCheckSellPrerequisiteUseCase extends Mock
    implements CheckSellPrerequisiteUseCase {}

/// Fake SellerRoleBloc seeded with a given state. [emitForTest] triggers
/// listener side-effects such as snackbar or navigation.
class _FakeSellerRoleBloc extends SellerRoleBloc {
  _FakeSellerRoleBloc([SellerRoleState initialState = const SellerRoleIdle()])
    : super(_MockMeRepository()) {
    if (initialState is! SellerRoleIdle) {
      emit(initialState);
    }
  }

  void emitForTest(SellerRoleState state) => emit(state);
}

Widget _wrap(_FakeSellerRoleBloc bloc, StackRouter router) {
  return BlocProvider<SellerRoleBloc>.value(
    value: bloc,
    child: MaterialApp(
      theme: dsTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: StackRouterScope(
        controller: router,
        stateHash: 0,
        child: const SellerRolePage(),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    // Fallback values for any() matchers over router params.
    registerFallbackValue(const SellRoute());
    registerFallbackValue(<PageRouteInfo>[]);
    registerFallbackValue(
      const SellerRoleSubmitted(role: SellerRole.particular),
    );
  });

  group('SellerRolePage', () {
    late _MockStackRouter router;
    late _FakeSellerRoleBloc bloc;

    setUp(() {
      router = _MockStackRouter();
      bloc = _FakeSellerRoleBloc();
      when(() => router.maybePop<Object?>()).thenAnswer((_) async => true);
    });

    tearDown(() => bloc.close());

    testWidgets('renders page title', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(bloc, router));
      await tester.pump();

      expect(find.text('How will you sell?'), findsOneWidget);
    });

    testWidgets('renders page subtitle', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(bloc, router));
      await tester.pump();

      expect(
        find.textContaining('Pick the account that fits you'),
        findsOneWidget,
      );
    });

    testWidgets('renders private seller and pro vendor option cards', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(bloc, router));
      await tester.pump();

      expect(find.text('Private seller'), findsOneWidget);
      expect(find.text('Professional vendor'), findsOneWidget);
      // Two DSOptionCard widgets — one per role.
      expect(find.byType(DSOptionCard), findsNWidgets(2));
    });

    testWidgets('Continue button is disabled when no role is selected', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(bloc, router));
      await tester.pump();

      // DSButtonElevated sets ElevatedButton.onPressed to null when disabled.
      final elevatedButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(elevatedButton.onPressed, isNull);
    });

    testWidgets('selecting private seller shows IBAN field', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(bloc, router));
      await tester.pump();

      // Tap the private seller DSOptionCard to select it.
      await tester.tap(find.byType(DSOptionCard).first);
      await tester.pump();

      // DSFieldLabel uses Text.rich, so textContaining is needed.
      expect(find.textContaining('Payout IBAN'), findsOneWidget);
    });

    testWidgets('Continue button shows loader in SellerRoleSubmitting', (
      WidgetTester tester,
    ) async {
      final submittingBloc = _FakeSellerRoleBloc(const SellerRoleSubmitting());
      addTearDown(submittingBloc.close);

      await tester.pumpWidget(_wrap(submittingBloc, router));
      await tester.pump();

      // DSButtonElevated renders CircularProgressIndicator when isLoading=true.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('back button calls router.maybePop', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(bloc, router));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pump();

      verify(() => router.maybePop<Object?>()).called(1);
    });

    testWidgets('shows snackbar on SellerRoleFailure', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(bloc, router));
      await tester.pump();

      bloc.emitForTest(
        const SellerRoleFailure("Couldn't save. Please try again."),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text("Couldn't save. Please try again."), findsOneWidget);
    });

    testWidgets(
      'SellerRoleDone checks prerequisite and navigates via locator',
      (WidgetTester tester) async {
        final mockUseCase = _MockCheckSellPrerequisiteUseCase();
        when(
          () => mockUseCase(),
        ).thenAnswer((_) async => SellPrerequisite.ready);

        // Register the mock in an isolated GetIt scope so we don't pollute the
        // global locator across tests.
        locator.pushNewScope(scopeName: 'seller-role-done-test');
        locator.registerFactory<CheckSellPrerequisiteUseCase>(
          () => mockUseCase,
        );
        when(
          () => router.replace<Object?>(
            any(),
            onFailure: any(named: 'onFailure'),
          ),
        ).thenAnswer((_) async => null);

        await tester.pumpWidget(_wrap(bloc, router));
        await tester.pump();

        bloc.emitForTest(const SellerRoleDone());
        // First pump: listener fires, _continueAfterRole is called (async).
        await tester.pump();
        // Second pump: usecase future resolves, router.replace() is called.
        await tester.pump();

        await locator.popScope();

        verify(
          () => router.replace<Object?>(
            any(),
            onFailure: any(named: 'onFailure'),
          ),
        ).called(1);
      },
    );
  });
}
