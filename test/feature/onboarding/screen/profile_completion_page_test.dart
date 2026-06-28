import 'package:auto_route/auto_route.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:klozy/src/domain/places/places_repository.dart';
import 'package:klozy/src/feature/onboarding/presentation/bloc/profile_completion_bloc.dart';
import 'package:klozy/src/feature/onboarding/presentation/bloc/profile_completion_state.dart';
import 'package:klozy/src/feature/onboarding/presentation/screen/profile_completion_page.dart';
import 'package:mocktail/mocktail.dart';

class _MockMeRepository extends Mock implements MeRepository {}

class _MockPlacesRepository extends Mock implements PlacesRepository {}

class _MockStackRouter extends Mock implements StackRouter {}

/// Fake bloc seeded with a given initial state; exposes [emitForTest] so tests
/// can trigger state transitions that exercise the listener side of the page.
class _FakeProfileCompletionBloc extends ProfileCompletionBloc {
  _FakeProfileCompletionBloc([
    ProfileCompletionState initialState = const ProfileCompletionIdle(),
  ]) : super(_MockMeRepository(), _MockPlacesRepository()) {
    if (initialState is! ProfileCompletionIdle) {
      emit(initialState);
    }
  }

  void emitForTest(ProfileCompletionState state) => emit(state);
}

Widget _wrap(_FakeProfileCompletionBloc bloc, StackRouter router) {
  return BlocProvider<ProfileCompletionBloc>.value(
    value: bloc,
    child: MaterialApp(
      theme: dsTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: StackRouterScope(
        controller: router,
        stateHash: 0,
        child: const ProfileCompletionPage(),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('ProfileCompletionPage', () {
    late _MockStackRouter router;
    late _FakeProfileCompletionBloc bloc;

    setUp(() {
      router = _MockStackRouter();
      bloc = _FakeProfileCompletionBloc();
      when(() => router.maybePop<Object?>()).thenAnswer((_) async => true);

      // AvatarUploadWidget calls locator<MeRepository>() in createState, and
      // locator<EventBus>() when uploading. Register both in a transient scope.
      locator.pushNewScope(scopeName: 'profile-completion-test');
      locator
        ..registerFactory<MeRepository>(() => _MockMeRepository())
        ..registerSingleton<EventBus>(EventBus());
    });

    tearDown(() async {
      await bloc.close();
      await locator.popScope();
    });

    testWidgets('renders page title', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(bloc, router));
      await tester.pump();

      expect(find.text('Complete your profile'), findsOneWidget);
    });

    testWidgets('renders page subtitle', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(bloc, router));
      await tester.pump();

      expect(
        find.text('This is how other members will see you on Klozy.'),
        findsOneWidget,
      );
    });

    testWidgets('renders first name, last name, address and bio fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(bloc, router));
      await tester.pump();

      // DSFieldLabel uses Text.rich so textContaining is needed.
      expect(find.textContaining('First name'), findsOneWidget);
      expect(find.textContaining('Last name'), findsOneWidget);
      expect(find.textContaining('Address'), findsOneWidget);
      expect(find.textContaining('Bio'), findsWidgets);
    });

    testWidgets('Continue button is disabled when form is empty', (
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

    testWidgets('Continue button shows loader in ProfileCompletionSubmitting', (
      WidgetTester tester,
    ) async {
      final submittingBloc = _FakeProfileCompletionBloc(
        const ProfileCompletionSubmitting(),
      );
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

    testWidgets('shows snackbar on ProfileCompletionFailure', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(bloc, router));
      await tester.pump();

      bloc.emitForTest(
        const ProfileCompletionFailure(
          "Couldn't save your profile. Please try again.",
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.text("Couldn't save your profile. Please try again."),
        findsOneWidget,
      );
    });
  });
}
