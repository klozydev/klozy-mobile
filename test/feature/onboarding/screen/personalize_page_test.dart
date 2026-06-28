import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/core/components/app_error_widget.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/domain/catalog/catalog_repository.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_brand.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_category.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:klozy/src/feature/onboarding/presentation/bloc/personalize_bloc.dart';
import 'package:klozy/src/feature/onboarding/presentation/bloc/personalize_state.dart';
import 'package:klozy/src/feature/onboarding/presentation/screen/personalize_page.dart';
import 'package:klozy/src/router/app_router.dart';
import 'package:mocktail/mocktail.dart';

class _MockCatalogRepository extends Mock implements CatalogRepository {}

class _MockMeRepository extends Mock implements MeRepository {}

class _MockStackRouter extends Mock implements StackRouter {}

/// Minimal PersonalizeBloc that starts in [initialState] without I/O.
class _FakePersonalizeBloc extends PersonalizeBloc {
  _FakePersonalizeBloc(PersonalizeState initialState)
    : super(_MockCatalogRepository(), _MockMeRepository()) {
    emit(initialState);
  }
}

const _kCategory = CatalogCategory(id: 'cat1', label: 'Women');
const _kBrand = CatalogBrand(id: 'b1', name: 'Nike');

const _kReadyState = PersonalizeReady(
  categories: <CatalogCategory>[_kCategory],
  brands: <CatalogBrand>[_kBrand],
);

Widget _wrap(PersonalizeState state, StackRouter router) {
  return BlocProvider<PersonalizeBloc>.value(
    value: _FakePersonalizeBloc(state),
    child: MaterialApp(
      theme: dsTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: StackRouterScope(
        controller: router,
        stateHash: 0,
        child: const PersonalizePage(),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    registerFallbackValue(const ProfileCompletionRoute());
  });

  group('PersonalizePage', () {
    late _MockStackRouter router;

    setUp(() {
      router = _MockStackRouter();
      when(
        () => router.push<Object?>(any(), onFailure: any(named: 'onFailure')),
      ).thenAnswer((_) async => null);
    });

    testWidgets('shows DSLoader in PersonalizeLoading state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(const PersonalizeLoading(), router));
      await tester.pump();

      expect(find.byType(DSLoader), findsOneWidget);
    });

    testWidgets('shows AppErrorWidget in PersonalizeFailure state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const PersonalizeFailure(AppErrorType.network), router),
      );
      await tester.pump();

      expect(find.byType(AppErrorWidget), findsOneWidget);
    });

    testWidgets('shows title and subtitle in PersonalizeReady state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(_kReadyState, router));
      await tester.pump();

      expect(find.text('Personalize your feed'), findsOneWidget);
      expect(find.textContaining('Pick a few things'), findsOneWidget);
    });

    testWidgets('shows Skip button in PersonalizeReady state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(_kReadyState, router));
      await tester.pump();

      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('tapping Skip pushes ProfileCompletionRoute', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(_kReadyState, router));
      await tester.pump();

      await tester.tap(find.text('Skip'));
      await tester.pump();

      final captured = verify(
        () => router.push<Object?>(
          captureAny(),
          onFailure: any(named: 'onFailure'),
        ),
      ).captured;
      expect(captured.single, isA<ProfileCompletionRoute>());
    });

    testWidgets('shows DSLoader in PersonalizeCompleted state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(const PersonalizeCompleted(), router));
      await tester.pump();

      expect(find.byType(DSLoader), findsOneWidget);
    });
  });
}
