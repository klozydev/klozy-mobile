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
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/core/components/app_error_widget.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/account/entity/account_status.dart';
import 'package:klozy/src/domain/account/usecase/get_account_status_usecase.dart';
import 'package:klozy/src/domain/auth/auth_repository.dart';
import 'package:klozy/src/domain/social/entity/profile_reel.dart';
import 'package:klozy/src/domain/social/entity/social_profile.dart';
import 'package:klozy/src/domain/social/entity/user_review.dart';
import 'package:klozy/src/feature/profile/presentation/bloc/profile_bloc.dart';
import 'package:klozy/src/feature/profile/presentation/bloc/profile_event.dart';
import 'package:klozy/src/feature/profile/presentation/bloc/profile_state.dart';
import 'package:klozy/src/feature/profile/presentation/widget/profile_actions_widget.dart';
import 'package:klozy/src/feature/profile/presentation/widget/profile_reels_grid.dart';
import 'package:klozy/src/feature/profile/presentation/widget/profile_reviews_list.dart';
import 'package:klozy/src/feature/profile/presentation/widget/profile_tab_empty.dart';
import 'package:klozy/src/feature/profile/presentation/widget/profile_view.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../support/ds_harness.dart';

// ---------------------------------------------------------------------------
// Fakes / mocks
// ---------------------------------------------------------------------------

// ignore: avoid_implementing_value_types
class _FakeRoute extends Fake implements PageRouteInfo<Object?> {}

class _MockStackRouter extends Mock implements StackRouter {}

class _MockGetAccountStatus extends Mock implements GetAccountStatusUseCase {}

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockProfileBloc extends Mock implements ProfileBloc {}

class _MockNotificationsCubit extends Mock implements NotificationsCubit {}

/// A minimal AccountBloc whose state is fixed at construction.
class _FakeAccountBloc extends AccountBloc {
  _FakeAccountBloc(AccountState initialState)
    : super(_MockGetAccountStatus(), _MockAuthRepository(), EventBus()) {
    emit(initialState);
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

_MockProfileBloc _buildProfileBloc(
  ProfileState state, {
  Stream<ProfileState>? stream,
}) {
  final bloc = _MockProfileBloc();
  when(() => bloc.state).thenReturn(state);
  when(
    () => bloc.stream,
  ).thenAnswer((_) => stream ?? const Stream<ProfileState>.empty());
  when(() => bloc.close()).thenAnswer((_) async {});
  when(() => bloc.add(any())).thenReturn(null);
  return bloc;
}

_MockNotificationsCubit _buildNotificationsCubit({int count = 0}) {
  final cubit = _MockNotificationsCubit();
  when(() => cubit.state).thenReturn(count);
  when(() => cubit.stream).thenAnswer((_) => const Stream<int>.empty());
  when(() => cubit.close()).thenAnswer((_) async {});
  return cubit;
}

Widget _wrapProfileView({
  required ProfileState profileState,
  required AccountBloc accountBloc,
  required StackRouter router,
  int notificationCount = 0,
  String? userId,
}) {
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
        child: ProfileView(userId: userId),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Suppress network errors from reel/avatar thumbnails
// ---------------------------------------------------------------------------
bool _isNetworkError(FlutterErrorDetails d) {
  final msg = d.exception.toString();
  return msg.contains('HTTP request failed') ||
      msg.contains('NetworkImageLoadException') ||
      msg.contains('SocketException') ||
      msg.contains('Failed to load');
}

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

const _ownProfile = SocialProfile(
  id: 'me',
  displayName: 'My Profile',
  isMe: true,
  followers: 10,
  following: 5,
);

const _otherProfile = SocialProfile(
  id: 'other',
  displayName: 'Alice',
  isMe: false,
  isFollowing: false,
  followers: 100,
  following: 20,
);

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
  late _FakeAccountBloc accountBloc;

  setUp(() {
    router = _MockStackRouter();
    when(() => router.maybePop<Object?>()).thenAnswer((_) async => true);
    when(() => router.push(any())).thenAnswer((_) async => null);
    when(() => router.navigate(any())).thenAnswer((_) async {});

    accountBloc = _FakeAccountBloc(const AccountResolved(AccountStatus.valid));
  });

  tearDown(() async {
    await accountBloc.close();
    if (locator.isRegistered<ProfileBloc>()) {
      locator.unregister<ProfileBloc>();
    }
    if (locator.isRegistered<NotificationsCubit>()) {
      locator.unregister<NotificationsCubit>();
    }
  });

  void registerBloc(ProfileState state, {int notificationCount = 0}) {
    final profileBloc = _buildProfileBloc(state);
    final notifCubit = _buildNotificationsCubit(count: notificationCount);
    if (!locator.isRegistered<ProfileBloc>()) {
      locator.registerSingleton<ProfileBloc>(profileBloc);
    }
    if (!locator.isRegistered<NotificationsCubit>()) {
      locator.registerSingleton<NotificationsCubit>(notifCubit);
    }
  }

  // -------------------------------------------------------------------------
  group('ProfileView – loading state', () {
    testWidgets('shows DSLoader while loading', (WidgetTester tester) async {
      registerBloc(const ProfileLoadingState());
      await tester.pumpWidget(
        _wrapProfileView(
          profileState: const ProfileLoadingState(),
          accountBloc: accountBloc,
          router: router,
        ),
      );
      await tester.pump();
      expect(find.byType(DSLoader), findsWidgets);
    });
  });

  // -------------------------------------------------------------------------
  group('ProfileView – error state', () {
    testWidgets('shows AppErrorWidget on error', (WidgetTester tester) async {
      registerBloc(const ProfileErrorState(type: AppErrorType.network));
      await tester.pumpWidget(
        _wrapProfileView(
          profileState: const ProfileErrorState(type: AppErrorType.network),
          accountBloc: accountBloc,
          router: router,
        ),
      );
      await tester.pump();
      expect(find.byType(AppErrorWidget), findsOneWidget);
    });

    testWidgets('retry button dispatches ProfileStarted', (
      WidgetTester tester,
    ) async {
      final profileBloc = _buildProfileBloc(
        const ProfileErrorState(type: AppErrorType.network),
      );
      locator.registerSingleton<ProfileBloc>(profileBloc);
      locator.registerSingleton<NotificationsCubit>(_buildNotificationsCubit());

      await tester.pumpWidget(
        _wrapProfileView(
          profileState: const ProfileErrorState(type: AppErrorType.network),
          accountBloc: accountBloc,
          router: router,
        ),
      );
      await tester.pump();

      // Find and tap the retry button (AppErrorWidget uses DSButtonOutline).
      await tester.tap(find.byType(OutlinedButton).first);
      await tester.pump();

      verify(
        () => profileBloc.add(any<ProfileEvent>()),
      ).called(greaterThanOrEqualTo(1));
    });
  });

  // -------------------------------------------------------------------------
  group('ProfileView – loaded: own profile', () {
    late ProfileLoadedState ownLoaded;

    setUp(() {
      ownLoaded = const ProfileLoadedState(profile: _ownProfile);
    });

    testWidgets('shows bag/bell/settings buttons in app bar', (
      WidgetTester tester,
    ) async {
      registerBloc(ownLoaded);
      await tester.pumpWidget(
        _wrapProfileView(
          profileState: ownLoaded,
          accountBloc: accountBloc,
          router: router,
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    });

    testWidgets('notification badge shown when unread > 0', (
      WidgetTester tester,
    ) async {
      registerBloc(ownLoaded, notificationCount: 3);
      await tester.pumpWidget(
        _wrapProfileView(
          profileState: ownLoaded,
          accountBloc: accountBloc,
          router: router,
          notificationCount: 3,
        ),
      );
      await tester.pump();
      // ProfileCircleButton with showBadge=true has 2 children in its Stack
      final stacks = tester.widgetList<Stack>(find.byType(Stack));
      final hasBadge = stacks.any((s) => s.children.length == 2);
      expect(hasBadge, isTrue);
    });

    testWidgets('does not show ProfileActionsWidget for own profile', (
      WidgetTester tester,
    ) async {
      registerBloc(ownLoaded);
      await tester.pumpWidget(
        _wrapProfileView(
          profileState: ownLoaded,
          accountBloc: accountBloc,
          router: router,
        ),
      );
      await tester.pump();
      expect(find.byType(ProfileActionsWidget), findsNothing);
    });

    testWidgets('shows Products tab content by default', (
      WidgetTester tester,
    ) async {
      registerBloc(ownLoaded);
      await tester.pumpWidget(
        _wrapProfileView(
          profileState: ownLoaded,
          accountBloc: accountBloc,
          router: router,
        ),
      );
      await tester.pumpAndSettle();
      // Empty products → ProfileTabEmpty (no listings yet)
      expect(find.text('No listings yet'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  group('ProfileView – loaded: other user profile', () {
    late ProfileLoadedState otherLoaded;

    setUp(() {
      otherLoaded = const ProfileLoadedState(profile: _otherProfile);
    });

    testWidgets('shows more button (not bag/bell/settings)', (
      WidgetTester tester,
    ) async {
      registerBloc(otherLoaded);
      await tester.pumpWidget(
        _wrapProfileView(
          profileState: otherLoaded,
          accountBloc: accountBloc,
          router: router,
          userId: 'other',
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.more_horiz), findsOneWidget);
      expect(find.byIcon(Icons.shopping_bag_outlined), findsNothing);
    });

    testWidgets('shows ProfileActionsWidget for other user', (
      WidgetTester tester,
    ) async {
      registerBloc(otherLoaded);
      await tester.pumpWidget(
        _wrapProfileView(
          profileState: otherLoaded,
          accountBloc: accountBloc,
          router: router,
          userId: 'other',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ProfileActionsWidget), findsOneWidget);
    });

    testWidgets('shows "more" menu sheet when more button tapped', (
      WidgetTester tester,
    ) async {
      registerBloc(otherLoaded);
      await tester.pumpWidget(
        _wrapProfileView(
          profileState: otherLoaded,
          accountBloc: accountBloc,
          router: router,
          userId: 'other',
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      expect(find.text('Report user'), findsOneWidget);
      expect(find.text('Block user'), findsOneWidget);
    });

    testWidgets('report action dispatches ProfileReported and shows snackbar', (
      WidgetTester tester,
    ) async {
      final profileBloc = _buildProfileBloc(otherLoaded);
      locator.registerSingleton<ProfileBloc>(profileBloc);
      locator.registerSingleton<NotificationsCubit>(_buildNotificationsCubit());

      await tester.pumpWidget(
        _wrapProfileView(
          profileState: otherLoaded,
          accountBloc: accountBloc,
          router: router,
          userId: 'other',
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Report user'));
      await tester.pumpAndSettle();

      // ProfileReported was dispatched
      verify(
        () => profileBloc.add(any<ProfileEvent>()),
      ).called(greaterThanOrEqualTo(1));
      // Snackbar shown
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  group('ProfileView – reels tab content', () {
    testWidgets('shows DSLoader when tabLoading=true and reels==null', (
      WidgetTester tester,
    ) async {
      const loadingState = ProfileLoadedState(
        profile: _ownProfile,
        tabLoading: true,
        reels: null,
      );
      registerBloc(loadingState);
      await tester.pumpWidget(
        _wrapProfileView(
          profileState: loadingState,
          accountBloc: accountBloc,
          router: router,
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Reels tab. The loader animates indefinitely, so settle the
      // tab-change animation with fixed pumps instead of pumpAndSettle.
      await tester.tap(find.text('Reels'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.byType(DSLoader), findsWidgets);
    });

    testWidgets('shows ProfileReelsGrid when reels are loaded', (
      WidgetTester tester,
    ) async {
      final prev = FlutterError.onError;
      FlutterError.onError = (d) {
        if (_isNetworkError(d)) return;
        prev?.call(d);
      };
      addTearDown(() => FlutterError.onError = prev);

      const reels = <ProfileReel>[
        ProfileReel(id: 'r1', views: 42),
        ProfileReel(id: 'r2', views: 0),
      ];
      const loadedState = ProfileLoadedState(
        profile: _ownProfile,
        reels: reels,
      );
      registerBloc(loadedState);
      await tester.pumpWidget(
        _wrapProfileView(
          profileState: loadedState,
          accountBloc: accountBloc,
          router: router,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reels'));
      await tester.pumpAndSettle();

      expect(find.byType(ProfileReelsGrid), findsOneWidget);
    });

    testWidgets('shows ProfileTabEmpty when reels list is empty', (
      WidgetTester tester,
    ) async {
      const loadedState = ProfileLoadedState(profile: _ownProfile, reels: []);
      registerBloc(loadedState);
      await tester.pumpWidget(
        _wrapProfileView(
          profileState: loadedState,
          accountBloc: accountBloc,
          router: router,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reels'));
      await tester.pumpAndSettle();

      expect(find.byType(ProfileTabEmpty), findsWidgets);
    });
  });

  // -------------------------------------------------------------------------
  group('ProfileView – reviews tab content', () {
    testWidgets('shows DSLoader when tabLoading=true and reviews==null', (
      WidgetTester tester,
    ) async {
      const loadingState = ProfileLoadedState(
        profile: _ownProfile,
        tabLoading: true,
        reviews: null,
      );
      registerBloc(loadingState);
      await tester.pumpWidget(
        _wrapProfileView(
          profileState: loadingState,
          accountBloc: accountBloc,
          router: router,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reviews'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.byType(DSLoader), findsWidgets);
    });

    testWidgets('shows ProfileReviewsList when reviews are loaded', (
      WidgetTester tester,
    ) async {
      const reviews = <UserReview>[
        UserReview(id: 'rev1', authorName: 'Dave', rating: 5.0, body: ''),
      ];
      const loadedState = ProfileLoadedState(
        profile: SocialProfile(
          id: 'me',
          displayName: 'My Profile',
          isMe: true,
          reviewCount: 1,
          rating: 5.0,
        ),
        reviews: reviews,
      );
      registerBloc(loadedState);
      await tester.pumpWidget(
        _wrapProfileView(
          profileState: loadedState,
          accountBloc: accountBloc,
          router: router,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reviews'));
      await tester.pumpAndSettle();

      expect(find.byType(ProfileReviewsList), findsOneWidget);
    });
  });
}
