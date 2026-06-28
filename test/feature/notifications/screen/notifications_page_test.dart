import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/app/notifications/notifications_cubit.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/core/components/app_error_widget.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/domain/notifications/entity/app_notification.dart';
import 'package:klozy/src/domain/notifications/entity/notification_type.dart';
import 'package:klozy/src/domain/notifications/notifications_repository.dart';
import 'package:klozy/src/feature/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:klozy/src/feature/notifications/presentation/bloc/notifications_state.dart';
import 'package:klozy/src/feature/notifications/presentation/screen/notifications_page.dart';
import 'package:klozy/src/feature/notifications/presentation/widget/notification_row_widget.dart';
import 'package:klozy/src/feature/notifications/presentation/widget/notification_skeleton_widget.dart';
import 'package:klozy/src/router/app_router.dart';
import 'package:mocktail/mocktail.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Mocks
// ─────────────────────────────────────────────────────────────────────────────

class _MockNotificationsRepository extends Mock
    implements NotificationsRepository {}

class _MockNotificationsCubit extends Mock implements NotificationsCubit {}

class _MockStackRouter extends Mock implements StackRouter {}

// ─────────────────────────────────────────────────────────────────────────────
// Fake bloc — pre-emits the target state, bypassing the loading skeleton.
// Same pattern as _FakeCartBloc in test/feature/cart/presentation/screen/.
// ─────────────────────────────────────────────────────────────────────────────

class _FakeNotificationsBloc extends NotificationsBloc {
  _FakeNotificationsBloc({
    required NotificationsRepository repo,
    required NotificationsCubit cubit,
    required NotificationsState initialState,
  }) : super(repo, cubit) {
    emit(initialState);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Wrap helper
// ─────────────────────────────────────────────────────────────────────────────

Widget _wrap(NotificationsBloc bloc, {required StackRouter router}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: dsTheme(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: BlocProvider<NotificationsBloc>.value(
      value: bloc,
      child: StackRouterScope(
        controller: router,
        stateHash: 0,
        child: const NotificationsPage(),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Fixtures
// ─────────────────────────────────────────────────────────────────────────────

const _kNotif = AppNotification(
  id: 'n1',
  type: NotificationType.newOrder,
  title: 'New order',
  body: 'Someone placed an order.',
  read: false,
);

const _kNotifConversation = AppNotification(
  id: 'n2',
  type: NotificationType.newReview,
  title: 'New review',
  body: 'You got a review.',
  read: false,
  conversationId: 'c1',
);

const _kNotifProduct = AppNotification(
  id: 'n3',
  type: NotificationType.priceDrop,
  title: 'Price drop',
  body: '',
  read: false,
  productId: 'p1',
);

const _kNotifOrder = AppNotification(
  id: 'n4',
  type: NotificationType.delivered,
  title: 'Order delivered',
  body: '',
  read: false,
  orderId: 'o1',
);

const _kNotifUser = AppNotification(
  id: 'n5',
  type: NotificationType.newFollower,
  title: 'New follower',
  body: '',
  read: false,
  userId: 'u1',
);

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  late _MockNotificationsRepository mockRepo;
  late _MockNotificationsCubit mockCubit;
  late _MockStackRouter router;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    registerFallbackValue(ChatThreadRoute(conversationId: 'x'));
    registerFallbackValue(ProductRoute(id: 'x'));
    registerFallbackValue(OrderDetailRoute(id: 'x'));
    registerFallbackValue(UserProfileRoute(userId: 'x'));
  });

  setUp(() {
    mockRepo = _MockNotificationsRepository();
    mockCubit = _MockNotificationsCubit();
    router = _MockStackRouter();

    when(() => mockCubit.refresh()).thenAnswer((_) async {});
    when(() => mockCubit.clear()).thenReturn(null);
    when(
      () => router.push<Object?>(any(), onFailure: any(named: 'onFailure')),
    ).thenAnswer((_) async => null);
    when(() => router.maybePop<Object?>()).thenAnswer((_) async => true);
  });

  // ── Loading ───────────────────────────────────────────────────────────────

  group('NotificationsPage — loading state', () {
    testWidgets('shows NotificationSkeletonWidget', (
      WidgetTester tester,
    ) async {
      final bloc = _FakeNotificationsBloc(
        repo: mockRepo,
        cubit: mockCubit,
        initialState: const NotificationsLoadingState(),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(_wrap(bloc, router: router));
      // Pump 1ms to drain the Duration.zero timers in ShimmerBoxWidget.initState.
      await tester.pump(const Duration(milliseconds: 1));

      expect(find.byType(NotificationSkeletonWidget), findsOneWidget);
    });
  });

  // ── Empty ─────────────────────────────────────────────────────────────────

  group('NotificationsPage — empty state', () {
    testWidgets('shows the all-caught-up message', (WidgetTester tester) async {
      final bloc = _FakeNotificationsBloc(
        repo: mockRepo,
        cubit: mockCubit,
        initialState: const NotificationsLoadedState(<AppNotification>[]),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(_wrap(bloc, router: router));
      await tester.pump();

      expect(find.text("You're all caught up."), findsOneWidget);
    });

    testWidgets('shows no NotificationRowWidget when empty', (
      WidgetTester tester,
    ) async {
      final bloc = _FakeNotificationsBloc(
        repo: mockRepo,
        cubit: mockCubit,
        initialState: const NotificationsLoadedState(<AppNotification>[]),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(_wrap(bloc, router: router));
      await tester.pump();

      expect(find.byType(NotificationRowWidget), findsNothing);
    });
  });

  // ── Loaded with items ─────────────────────────────────────────────────────

  group('NotificationsPage — loaded state with items', () {
    late _FakeNotificationsBloc bloc;

    setUp(() {
      bloc = _FakeNotificationsBloc(
        repo: mockRepo,
        cubit: mockCubit,
        initialState: const NotificationsLoadedState(<AppNotification>[
          _kNotif,
        ]),
      );
      addTearDown(bloc.close);
    });

    testWidgets('shows one NotificationRowWidget and notification title', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(bloc, router: router));
      await tester.pump();

      expect(find.byType(NotificationRowWidget), findsOneWidget);
      expect(find.text(_kNotif.title), findsOneWidget);
    });

    testWidgets('shows app bar title "Notifications"', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(bloc, router: router));
      await tester.pump();

      expect(find.text('Notifications'), findsOneWidget);
    });

    testWidgets('shows "Read all" action button', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(bloc, router: router));
      await tester.pump();

      expect(find.text('Read all'), findsOneWidget);
    });
  });

  // ── Error ─────────────────────────────────────────────────────────────────

  group('NotificationsPage — error state', () {
    testWidgets('shows AppErrorWidget on network error', (
      WidgetTester tester,
    ) async {
      final bloc = _FakeNotificationsBloc(
        repo: mockRepo,
        cubit: mockCubit,
        initialState: const NotificationsErrorState(type: AppErrorType.network),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(_wrap(bloc, router: router));
      await tester.pump();

      expect(find.byType(AppErrorWidget), findsOneWidget);
      expect(find.text('No connection'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('tapping retry transitions to loaded state', (
      WidgetTester tester,
    ) async {
      when(
        () => mockRepo.getNotifications(),
      ).thenAnswer((_) async => <AppNotification>[]);
      when(() => mockRepo.markAllRead()).thenAnswer((_) async {});

      final bloc = _FakeNotificationsBloc(
        repo: mockRepo,
        cubit: mockCubit,
        initialState: const NotificationsErrorState(type: AppErrorType.unknown),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(_wrap(bloc, router: router));
      await tester.pump();

      await tester.tap(find.text('Try again'));
      // pump once to dispatch event + process async repo call
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text("You're all caught up."), findsOneWidget);
    });
  });

  // ── Interactions ──────────────────────────────────────────────────────────

  group('NotificationsPage — interactions', () {
    late _FakeNotificationsBloc bloc;

    setUp(() {
      when(() => mockRepo.markAllRead()).thenAnswer((_) async {});
      when(() => mockRepo.markRead(any())).thenAnswer((_) async {});
      when(() => mockRepo.remove(any())).thenAnswer((_) async {});

      bloc = _FakeNotificationsBloc(
        repo: mockRepo,
        cubit: mockCubit,
        initialState: const NotificationsLoadedState(<AppNotification>[
          _kNotif,
        ]),
      );
      addTearDown(bloc.close);
    });

    testWidgets('"Read all" button calls repo.markAllRead', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(bloc, router: router));
      await tester.pump();

      await tester.tap(find.text('Read all'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      verify(() => mockRepo.markAllRead()).called(1);
    });

    testWidgets('tapping delete icon calls repo.remove', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(bloc, router: router));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.close).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      verify(() => mockRepo.remove(_kNotif.id)).called(1);
    });

    testWidgets('back button calls router.maybePop', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(bloc, router: router));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pump();

      verify(() => router.maybePop<Object?>()).called(1);
    });

    testWidgets('tapping a row calls repo.markRead', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(bloc, router: router));
      await tester.pump();

      await tester.tap(find.text(_kNotif.title));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      verify(() => mockRepo.markRead(_kNotif.id)).called(1);
    });
  });

  // ── Navigation ────────────────────────────────────────────────────────────

  group('NotificationsPage — navigation on tap', () {
    Future<void> pumpWithItem(WidgetTester tester, AppNotification item) async {
      when(() => mockRepo.markRead(any())).thenAnswer((_) async {});
      final bloc = _FakeNotificationsBloc(
        repo: mockRepo,
        cubit: mockCubit,
        initialState: NotificationsLoadedState(<AppNotification>[item]),
      );
      addTearDown(bloc.close);
      await tester.pumpWidget(_wrap(bloc, router: router));
      await tester.pump();
    }

    testWidgets('conversationId → pushes ChatThreadRoute', (
      WidgetTester tester,
    ) async {
      await pumpWithItem(tester, _kNotifConversation);
      await tester.tap(find.text(_kNotifConversation.title));
      await tester.pump();

      final captured = verify(
        () => router.push<Object?>(
          captureAny(),
          onFailure: any(named: 'onFailure'),
        ),
      ).captured;
      expect(captured.single, isA<ChatThreadRoute>());
    });

    testWidgets('productId → pushes ProductRoute', (WidgetTester tester) async {
      await pumpWithItem(tester, _kNotifProduct);
      await tester.tap(find.text(_kNotifProduct.title));
      await tester.pump();

      final captured = verify(
        () => router.push<Object?>(
          captureAny(),
          onFailure: any(named: 'onFailure'),
        ),
      ).captured;
      expect(captured.single, isA<ProductRoute>());
    });

    testWidgets('orderId → pushes OrderDetailRoute', (
      WidgetTester tester,
    ) async {
      await pumpWithItem(tester, _kNotifOrder);
      await tester.tap(find.text(_kNotifOrder.title));
      await tester.pump();

      final captured = verify(
        () => router.push<Object?>(
          captureAny(),
          onFailure: any(named: 'onFailure'),
        ),
      ).captured;
      expect(captured.single, isA<OrderDetailRoute>());
    });

    testWidgets('userId → pushes UserProfileRoute', (
      WidgetTester tester,
    ) async {
      await pumpWithItem(tester, _kNotifUser);
      await tester.tap(find.text(_kNotifUser.title));
      await tester.pump();

      final captured = verify(
        () => router.push<Object?>(
          captureAny(),
          onFailure: any(named: 'onFailure'),
        ),
      ).captured;
      expect(captured.single, isA<UserProfileRoute>());
    });

    testWidgets('no linked id → does not push any route', (
      WidgetTester tester,
    ) async {
      await pumpWithItem(tester, _kNotif);
      await tester.tap(find.text(_kNotif.title));
      await tester.pump();

      verifyNever(
        () => router.push<Object?>(any(), onFailure: any(named: 'onFailure')),
      );
    });
  });
}
