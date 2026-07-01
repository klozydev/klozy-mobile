import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/core/components/app_error_widget.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/components/ds_segmented_control.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/social/entity/follow_user.dart';
import 'package:klozy/src/feature/profile/presentation/bloc/follow_list_bloc.dart';
import 'package:klozy/src/feature/profile/presentation/bloc/follow_list_event.dart';
import 'package:klozy/src/feature/profile/presentation/bloc/follow_list_state.dart';
import 'package:klozy/src/feature/profile/presentation/screen/follow_list_page.dart';
import 'package:klozy/src/feature/profile/presentation/widget/follow_user_row_widget.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../support/ds_harness.dart';

// ---------------------------------------------------------------------------
// Fakes / mocks
// ---------------------------------------------------------------------------

// ignore: avoid_implementing_value_types
class _FakeRoute extends Fake implements PageRouteInfo<Object?> {}

class _MockStackRouter extends Mock implements StackRouter {}

class _MockFollowListBloc extends Mock implements FollowListBloc {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

_MockFollowListBloc _buildBloc(
  FollowListState state, {
  Stream<FollowListState>? stream,
}) {
  final bloc = _MockFollowListBloc();
  when(() => bloc.state).thenReturn(state);
  when(
    () => bloc.stream,
  ).thenAnswer((_) => stream ?? const Stream<FollowListState>.empty());
  when(() => bloc.close()).thenAnswer((_) async {});
  when(() => bloc.add(any())).thenReturn(null);
  return bloc;
}

Widget _wrapWithBloc({
  required FollowListBloc bloc,
  required StackRouter router,
  String userId = 'u1',
  bool showFollowers = true,
}) {
  return BlocProvider<FollowListBloc>.value(
    value: bloc,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: dsTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: StackRouterScope(
        controller: router,
        stateHash: 0,
        child: FollowListPage(userId: userId, showFollowers: showFollowers),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

const _followers = <FollowUser>[
  FollowUser(id: 'f1', displayName: 'FollowerA', isFollowing: false),
  FollowUser(id: 'f2', displayName: 'FollowerB', isFollowing: true),
];

const _following = <FollowUser>[
  FollowUser(id: 'g1', displayName: 'FollowingA', isFollowing: true),
];

void main() {
  setUpAll(() {
    disableDsFonts();
    registerFallbackValue(_FakeRoute());
    registerFallbackValue(const FollowListStarted('u1'));
  });

  late _MockStackRouter router;

  setUp(() {
    router = _MockStackRouter();
    when(() => router.maybePop<Object?>()).thenAnswer((_) async => true);
    when(() => router.push(any())).thenAnswer((_) async => null);
  });

  tearDown(() {
    if (locator.isRegistered<FollowListBloc>()) {
      locator.unregister<FollowListBloc>();
    }
  });

  // -------------------------------------------------------------------------
  group('FollowListPage – states', () {
    testWidgets('shows DSLoader on loading state', (WidgetTester tester) async {
      final bloc = _buildBloc(const FollowListLoadingState());
      await tester.pumpWidget(_wrapWithBloc(bloc: bloc, router: router));
      await tester.pump();
      expect(find.byType(DSLoader), findsOneWidget);
    });

    testWidgets('shows AppErrorWidget on error state', (
      WidgetTester tester,
    ) async {
      final bloc = _buildBloc(
        const FollowListErrorState(type: AppErrorType.network),
      );
      await tester.pumpWidget(_wrapWithBloc(bloc: bloc, router: router));
      await tester.pump();
      expect(find.byType(AppErrorWidget), findsOneWidget);
    });

    testWidgets('retry button dispatches FollowListStarted on error', (
      WidgetTester tester,
    ) async {
      final bloc = _buildBloc(
        const FollowListErrorState(type: AppErrorType.unknown),
      );
      await tester.pumpWidget(_wrapWithBloc(bloc: bloc, router: router));
      await tester.pump();
      // AppErrorWidget's retry uses DSButtonOutline (OutlinedButton).
      await tester.tap(find.byType(OutlinedButton).first);
      await tester.pump();
      verify(
        () => bloc.add(any<FollowListEvent>()),
      ).called(greaterThanOrEqualTo(1));
    });

    testWidgets('shows follower rows on loaded state (followers tab)', (
      WidgetTester tester,
    ) async {
      final bloc = _buildBloc(
        const FollowListLoadedState(
          followers: _followers,
          following: _following,
        ),
      );
      await tester.pumpWidget(
        _wrapWithBloc(bloc: bloc, router: router, showFollowers: true),
      );
      await tester.pump();
      expect(
        find.byType(FollowUserRowWidget),
        findsNWidgets(_followers.length),
      );
      expect(find.text('FollowerA'), findsOneWidget);
      expect(find.text('FollowerB'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  group('FollowListPage – tab switching', () {
    testWidgets('starts on Followers tab when showFollowers=true', (
      WidgetTester tester,
    ) async {
      final bloc = _buildBloc(
        const FollowListLoadedState(
          followers: _followers,
          following: _following,
        ),
      );
      await tester.pumpWidget(
        _wrapWithBloc(bloc: bloc, router: router, showFollowers: true),
      );
      await tester.pump();
      expect(find.text('FollowerA'), findsOneWidget);
    });

    testWidgets('starts on Following tab when showFollowers=false', (
      WidgetTester tester,
    ) async {
      final bloc = _buildBloc(
        const FollowListLoadedState(
          followers: _followers,
          following: _following,
        ),
      );
      await tester.pumpWidget(
        _wrapWithBloc(bloc: bloc, router: router, showFollowers: false),
      );
      await tester.pump();
      expect(find.text('FollowingA'), findsOneWidget);
    });

    testWidgets('switching to Following tab shows following users', (
      WidgetTester tester,
    ) async {
      final bloc = _buildBloc(
        const FollowListLoadedState(
          followers: _followers,
          following: _following,
        ),
      );
      await tester.pumpWidget(
        _wrapWithBloc(bloc: bloc, router: router, showFollowers: true),
      );
      await tester.pump();

      // "Following" also labels a follow button on each row — scope the tap to
      // the segmented control that switches tabs.
      await tester.tap(
        find.descendant(
          of: find.byType(DSSegmentedControl),
          matching: find.text('Following'),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('FollowingA'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  group('FollowListPage – empty list messages', () {
    testWidgets('shows no-followers message when followers list is empty', (
      WidgetTester tester,
    ) async {
      final bloc = _buildBloc(
        const FollowListLoadedState(followers: [], following: _following),
      );
      await tester.pumpWidget(
        _wrapWithBloc(bloc: bloc, router: router, showFollowers: true),
      );
      await tester.pump();
      expect(find.text('No followers yet'), findsOneWidget);
    });

    testWidgets('shows no-following message when following list is empty', (
      WidgetTester tester,
    ) async {
      final bloc = _buildBloc(
        const FollowListLoadedState(followers: _followers, following: []),
      );
      await tester.pumpWidget(
        _wrapWithBloc(bloc: bloc, router: router, showFollowers: false),
      );
      await tester.pump();
      expect(find.text('Not following anyone yet'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  group('FollowListPage – follow toggle', () {
    testWidgets('tapping follow button dispatches FollowListRowToggled', (
      WidgetTester tester,
    ) async {
      final bloc = _buildBloc(
        const FollowListLoadedState(
          followers: [
            FollowUser(id: 'f1', displayName: 'UserX', isFollowing: false),
          ],
          following: [],
        ),
      );
      await tester.pumpWidget(
        _wrapWithBloc(bloc: bloc, router: router, showFollowers: true),
      );
      await tester.pump();
      await tester.tap(find.text('Follow'));
      await tester.pump();
      verify(
        () => bloc.add(any<FollowListEvent>()),
      ).called(greaterThanOrEqualTo(1));
    });
  });

  // -------------------------------------------------------------------------
  group('FollowListPage – navigation', () {
    testWidgets('back button calls router.maybePop', (
      WidgetTester tester,
    ) async {
      final bloc = _buildBloc(const FollowListLoadingState());
      await tester.pumpWidget(_wrapWithBloc(bloc: bloc, router: router));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      verify(() => router.maybePop<Object?>()).called(1);
    });

    testWidgets('tapping user row pushes UserProfileRoute', (
      WidgetTester tester,
    ) async {
      final bloc = _buildBloc(
        const FollowListLoadedState(
          followers: [
            FollowUser(id: 'f1', displayName: 'UserY', isFollowing: false),
          ],
          following: [],
        ),
      );
      await tester.pumpWidget(
        _wrapWithBloc(bloc: bloc, router: router, showFollowers: true),
      );
      await tester.pump();
      // Tap the user row (the username text area)
      await tester.tap(find.text('UserY'));
      await tester.pump();
      verify(() => router.push(any())).called(greaterThanOrEqualTo(1));
    });
  });

  // -------------------------------------------------------------------------
  group('FollowListPage – wrappedRoute', () {
    testWidgets('wrappedRoute injects FollowListBloc from locator', (
      WidgetTester tester,
    ) async {
      final bloc = _buildBloc(const FollowListLoadingState());
      locator.registerSingleton<FollowListBloc>(bloc);

      const page = FollowListPage(userId: 'u1');
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: dsTheme(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: StackRouterScope(
            controller: router,
            stateHash: 0,
            child: Builder(builder: (ctx) => page.wrappedRoute(ctx)),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(DSLoader), findsOneWidget);
    });
  });
}
