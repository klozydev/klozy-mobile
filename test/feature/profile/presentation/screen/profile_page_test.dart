import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/app/bloc/account/account_bloc.dart';
import 'package:klozy/src/app/bloc/account/account_state.dart';
import 'package:klozy/src/app/notifications/notifications_cubit.dart';
import 'package:klozy/src/core/account/guest_tab_placeholder_widget.dart';
import 'package:klozy/src/core/account/incomplete_profile_placeholder_widget.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/account/entity/account_status.dart';
import 'package:klozy/src/domain/account/usecase/get_account_status_usecase.dart';
import 'package:klozy/src/domain/auth/auth_repository.dart';
import 'package:klozy/src/domain/social/entity/social_profile.dart';
import 'package:klozy/src/feature/profile/presentation/bloc/profile_bloc.dart';
import 'package:klozy/src/feature/profile/presentation/bloc/profile_event.dart';
import 'package:klozy/src/feature/profile/presentation/bloc/profile_state.dart';
import 'package:klozy/src/feature/profile/presentation/screen/profile_page.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../support/ds_harness.dart';

// ---------------------------------------------------------------------------
// Fakes / mocks
// ---------------------------------------------------------------------------

class _FakeRoute extends Fake implements PageRouteInfo<Object?> {}

class _MockStackRouter extends Mock implements StackRouter {}

class _MockGetAccountStatus extends Mock implements GetAccountStatusUseCase {}

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockProfileBloc extends Mock implements ProfileBloc {}

class _MockNotificationsCubit extends Mock implements NotificationsCubit {}

/// Minimal AccountBloc that emits a fixed state and ignores events.
class _FakeAccountBloc extends AccountBloc {
  _FakeAccountBloc(AccountState initialState)
    : super(_MockGetAccountStatus(), _MockAuthRepository(), EventBus()) {
    emit(initialState);
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

_MockProfileBloc _buildProfileBloc(ProfileState state) {
  final bloc = _MockProfileBloc();
  when(() => bloc.state).thenReturn(state);
  when(() => bloc.stream).thenAnswer((_) => const Stream<ProfileState>.empty());
  when(() => bloc.close()).thenAnswer((_) async {});
  when(() => bloc.add(any())).thenReturn(null);
  return bloc;
}

_MockNotificationsCubit _buildNotificationsCubit() {
  final cubit = _MockNotificationsCubit();
  when(() => cubit.state).thenReturn(0);
  when(() => cubit.stream).thenAnswer((_) => const Stream<int>.empty());
  when(() => cubit.close()).thenAnswer((_) async {});
  return cubit;
}

Widget _wrapWithAccount(AccountBloc accountBloc, StackRouter router) {
  return BlocProvider<AccountBloc>.value(
    value: accountBloc,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: dsTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: StackRouterScope(
        controller: router,
        stateHash: 0,
        child: const ProfilePage(),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    disableDsFonts();
    registerFallbackValue(_FakeRoute());
    registerFallbackValue(const ProfileStarted());
  });

  late _MockStackRouter router;

  setUp(() {
    router = _MockStackRouter();
    when(() => router.maybePop<Object?>()).thenAnswer((_) async => true);
    when(() => router.push(any())).thenAnswer((_) async => null);
  });

  tearDown(() async {
    if (locator.isRegistered<ProfileBloc>()) {
      locator.unregister<ProfileBloc>();
    }
    if (locator.isRegistered<NotificationsCubit>()) {
      locator.unregister<NotificationsCubit>();
    }
  });

  // -------------------------------------------------------------------------
  group('ProfilePage – account states without ProfileView', () {
    testWidgets('shows DSLoader when AccountInitial', (
      WidgetTester tester,
    ) async {
      final accountBloc = _FakeAccountBloc(const AccountInitial());
      addTearDown(accountBloc.close);

      await tester.pumpWidget(_wrapWithAccount(accountBloc, router));
      await tester.pump();
      expect(find.byType(DSLoader), findsOneWidget);
    });

    testWidgets('shows DSLoader when AccountResolving', (
      WidgetTester tester,
    ) async {
      final accountBloc = _FakeAccountBloc(const AccountResolving());
      addTearDown(accountBloc.close);

      await tester.pumpWidget(_wrapWithAccount(accountBloc, router));
      await tester.pump();
      expect(find.byType(DSLoader), findsOneWidget);
    });

    testWidgets('shows GuestTabPlaceholderWidget when status=guest', (
      WidgetTester tester,
    ) async {
      final accountBloc = _FakeAccountBloc(
        const AccountResolved(AccountStatus.guest),
      );
      addTearDown(accountBloc.close);

      await tester.pumpWidget(_wrapWithAccount(accountBloc, router));
      await tester.pump();
      expect(find.byType(GuestTabPlaceholderWidget), findsOneWidget);
    });

    testWidgets(
      'shows IncompleteProfilePlaceholderWidget when status=incompleteOnboarding',
      (WidgetTester tester) async {
        final accountBloc = _FakeAccountBloc(
          const AccountResolved(AccountStatus.incompleteOnboarding),
        );
        addTearDown(accountBloc.close);

        await tester.pumpWidget(_wrapWithAccount(accountBloc, router));
        await tester.pump();
        expect(find.byType(IncompleteProfilePlaceholderWidget), findsOneWidget);
      },
    );
  });

  // -------------------------------------------------------------------------
  group('ProfilePage – valid account shows ProfileView via locator', () {
    testWidgets('shows DSLoader when profile bloc is loading', (
      WidgetTester tester,
    ) async {
      final profileBloc = _buildProfileBloc(const ProfileLoadingState());
      locator.registerSingleton<ProfileBloc>(profileBloc);
      locator.registerSingleton<NotificationsCubit>(_buildNotificationsCubit());

      final accountBloc = _FakeAccountBloc(
        const AccountResolved(AccountStatus.valid),
      );
      addTearDown(accountBloc.close);

      await tester.pumpWidget(_wrapWithAccount(accountBloc, router));
      await tester.pump();
      expect(find.byType(DSLoader), findsWidgets);
    });

    testWidgets('shows profile display name when profile is loaded', (
      WidgetTester tester,
    ) async {
      const profile = SocialProfile(
        id: 'me',
        displayName: 'Own User',
        isMe: true,
      );
      final profileBloc = _buildProfileBloc(
        const ProfileLoadedState(profile: profile),
      );
      locator.registerSingleton<ProfileBloc>(profileBloc);
      locator.registerSingleton<NotificationsCubit>(_buildNotificationsCubit());

      final accountBloc = _FakeAccountBloc(
        const AccountResolved(AccountStatus.valid),
      );
      addTearDown(accountBloc.close);

      await tester.pumpWidget(_wrapWithAccount(accountBloc, router));
      await tester.pumpAndSettle();
      expect(find.text('Own User'), findsOneWidget);
    });

    testWidgets(
      'rebuilds when account status changes from resolving to valid',
      (WidgetTester tester) async {
        final profileBloc = _buildProfileBloc(const ProfileLoadingState());
        locator.registerSingleton<ProfileBloc>(profileBloc);
        locator.registerSingleton<NotificationsCubit>(
          _buildNotificationsCubit(),
        );

        final stateController = StreamController<AccountState>.broadcast();
        final accountBloc = _FakeAccountBloc(const AccountResolving());
        addTearDown(() async {
          await accountBloc.close();
          await stateController.close();
        });

        await tester.pumpWidget(_wrapWithAccount(accountBloc, router));
        await tester.pump();
        expect(find.byType(DSLoader), findsWidgets);

        // Move to valid
        accountBloc.emit(const AccountResolved(AccountStatus.valid));
        await tester.pump();
        // DSLoader still present (profile is in loading state)
        expect(find.byType(DSLoader), findsWidgets);
      },
    );
  });
}
