import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/app/cart/cart_cubit.dart';
import 'package:klozy/src/app/notifications/notifications_cubit.dart';
import 'package:klozy/src/app/push/push_service.dart';
import 'package:klozy/src/app/wishlist/wishlist_cubit.dart';
import 'package:klozy/src/core/account/account_gate.dart';
import 'package:klozy/src/design/components/ds_cart_badge.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/cart/cart_repository.dart';
import 'package:klozy/src/core/pagination/paginated_list.dart';
import 'package:klozy/src/domain/cart/entity/cart.dart';
import 'package:klozy/src/domain/catalog/catalog_repository.dart';
import 'package:klozy/src/domain/config/public_config_repository.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:klozy/src/domain/notifications/notifications_repository.dart';
import 'package:klozy/src/domain/me/entity/me_profile.dart';
import 'package:klozy/src/domain/product/entity/feed_page.dart';
import 'package:klozy/src/domain/product/entity/product.dart';
import 'package:klozy/src/domain/product/products_repository.dart';
import 'package:klozy/src/domain/wishlist/wishlist_repository.dart';
import 'package:klozy/src/feature/home/presentation/bloc/feed_bloc.dart';
import 'package:klozy/src/feature/home/presentation/bloc/feed_event.dart';
import 'package:klozy/src/feature/home/presentation/bloc/feed_state.dart';
import 'package:klozy/src/feature/home/presentation/screen/home_page.dart';
import 'package:klozy/src/feature/home/presentation/widget/reels_cart_button_widget.dart';
import 'package:klozy/src/feature/home/presentation/widget/shell_tabs_widget.dart';
import 'package:klozy/src/feature/reels/domain/entity/reel.dart';
import 'package:klozy/src/feature/reels/domain/reels_repository.dart';
import 'package:klozy/src/feature/reels/presentation/bloc/reels_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../support/ds_harness.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class _MockPushService extends Mock implements PushService {}

class _MockAccountGate extends Mock implements AccountGate {}

class _MockPublicConfigRepository extends Mock
    implements PublicConfigRepository {}

class _MockWishlistRepository extends Mock implements WishlistRepository {}

class _MockCartRepository extends Mock implements CartRepository {}

class _MockNotificationsRepository extends Mock
    implements NotificationsRepository {}

class _MockReelsRepository extends Mock implements ReelsRepository {}

class _MockMeRepository extends Mock implements MeRepository {}

class _MockTabsRouter extends Mock implements TabsRouter {}

// ---------------------------------------------------------------------------
// Fixed-state FeedBloc (same pattern as feed_tab_widget_test)
// ---------------------------------------------------------------------------

class _MockProductsRepository extends Mock implements ProductsRepository {}

class _MockCatalogRepository extends Mock implements CatalogRepository {}

class _FixedStateFeedBloc extends FeedBloc {
  final FeedState _fixed;

  _FixedStateFeedBloc(this._fixed)
    : super(_MockProductsRepository(), _MockCatalogRepository(), EventBus());

  @override
  FeedState get state => _fixed;

  @override
  Stream<FeedState> get stream => Stream.value(_fixed);
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    disableDsFonts();
  });

  late _MockPushService mockPushService;
  late _MockAccountGate mockAccountGate;
  late _MockPublicConfigRepository mockPublicConfigRepo;
  late _MockWishlistRepository mockWishlistRepo;
  late _MockCartRepository mockCartRepo;
  late _MockNotificationsRepository mockNotificationsRepo;
  late _MockReelsRepository mockReelsRepo;
  late _MockMeRepository mockMeRepo;
  late _MockTabsRouter mockTabsRouter;
  late EventBus eventBus;

  setUp(() {
    mockPushService = _MockPushService();
    mockAccountGate = _MockAccountGate();
    mockPublicConfigRepo = _MockPublicConfigRepository();
    mockWishlistRepo = _MockWishlistRepository();
    mockCartRepo = _MockCartRepository();
    mockNotificationsRepo = _MockNotificationsRepository();
    mockReelsRepo = _MockReelsRepository();
    mockMeRepo = _MockMeRepository();
    mockTabsRouter = _MockTabsRouter();
    eventBus = EventBus();

    // TabsRouter stubs (called in didChangeDependencies + dispose).
    when(() => mockTabsRouter.activeIndex).thenReturn(0);
    when(() => mockTabsRouter.addListener(any())).thenReturn(null);
    when(() => mockTabsRouter.removeListener(any())).thenReturn(null);

    // Service stubs.
    when(() => mockPushService.init()).thenAnswer((_) async {});
    when(
      () => mockPublicConfigRepo.getPendingLegal(),
    ).thenAnswer((_) async => []);

    // Cubit-backing repo stubs.
    when(
      () => mockWishlistRepo.getWishlistProductIds(),
    ).thenAnswer((_) async => <String>{});
    when(
      () => mockWishlistRepo.getWishlistProducts(),
    ).thenAnswer((_) => Completer<PaginatedList<Product>>().future);
    when(() => mockCartRepo.getCart()).thenAnswer((_) async => Cart.empty);
    when(() => mockNotificationsRepo.unreadCount()).thenAnswer((_) async => 0);

    // Reels-feature stubs — ReelViewerWidget resolves these from the locator.
    // Use Completer.future so they never resolve (no timers, bloc stays loading).
    when(
      () => mockReelsRepo.feed(
        page: any(named: 'page'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) => Completer<PaginatedList<Reel>>().future);
    when(
      () => mockMeRepo.getMe(),
    ).thenAnswer((_) => Completer<MeProfile>().future);

    // Register in get_it.
    void reg<T extends Object>(T instance) {
      if (locator.isRegistered<T>()) locator.unregister<T>();
      locator.registerSingleton<T>(instance);
    }

    reg<EventBus>(eventBus);
    reg<PushService>(mockPushService);
    reg<AccountGate>(mockAccountGate);
    reg<PublicConfigRepository>(mockPublicConfigRepo);
    reg<WishlistRepository>(mockWishlistRepo);
    reg<MeRepository>(mockMeRepo);

    // ReelsBloc is @injectable (factory) — register a factory.
    if (locator.isRegistered<ReelsBloc>()) locator.unregister<ReelsBloc>();
    locator.registerFactory<ReelsBloc>(
      () => ReelsBloc(mockReelsRepo, eventBus),
    );
  });

  tearDown(() {
    for (final unregister in <void Function()>[
      () {
        if (locator.isRegistered<EventBus>()) locator.unregister<EventBus>();
      },
      () {
        if (locator.isRegistered<PushService>()) {
          locator.unregister<PushService>();
        }
      },
      () {
        if (locator.isRegistered<AccountGate>()) {
          locator.unregister<AccountGate>();
        }
      },
      () {
        if (locator.isRegistered<PublicConfigRepository>()) {
          locator.unregister<PublicConfigRepository>();
        }
      },
      () {
        if (locator.isRegistered<WishlistRepository>()) {
          locator.unregister<WishlistRepository>();
        }
      },
      () {
        if (locator.isRegistered<MeRepository>()) {
          locator.unregister<MeRepository>();
        }
      },
      () {
        if (locator.isRegistered<ReelsBloc>()) {
          locator.unregister<ReelsBloc>();
        }
      },
    ]) {
      unregister();
    }
  });

  Widget buildPage() {
    final feedBloc = _FixedStateFeedBloc(
      const FeedReady(categories: [], items: []),
    );
    final cartCubit = CartCubit(mockCartRepo);
    final notifCubit = NotificationsCubit(mockNotificationsRepo);
    final wishlistCubit = WishlistCubit(mockWishlistRepo, eventBus);

    return dsWrap(
      MultiBlocProvider(
        providers: [
          BlocProvider<FeedBloc>.value(value: feedBloc),
          BlocProvider<CartCubit>.value(value: cartCubit),
          BlocProvider<NotificationsCubit>.value(value: notifCubit),
          BlocProvider<WishlistCubit>.value(value: wishlistCubit),
        ],
        child: TabsRouterScope(
          stateHash: 0,
          controller: mockTabsRouter,
          child: const HomePage(),
        ),
      ),
    );
  }

  group('HomePage', () {
    testWidgets('renders Feed, Wishlist, Reels tab labels', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.text('Feed'), findsOneWidget);
      expect(find.text('Wishlist'), findsOneWidget);
      expect(find.text('Reels'), findsOneWidget);
    });

    testWidgets('renders ShellTabsWidget', (WidgetTester tester) async {
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byType(ShellTabsWidget), findsOneWidget);
    });

    testWidgets('shows DSCartBadge on Feed tab (non-overlay)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildPage());
      await tester.pump();

      // Feed tab (index 0) → non-overlay mode → DSCartBadge
      expect(find.byType(DSCartBadge), findsOneWidget);
    });

    testWidgets('switching to Reels tab shows ReelsCartButtonWidget', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildPage());
      await tester.pump();

      // Tap the Reels tab.
      await tester.tap(find.text('Reels'));
      await tester.pump();

      expect(find.byType(ReelsCartButtonWidget), findsOneWidget);
      expect(find.byType(DSCartBadge), findsNothing);
    });

    testWidgets('switching back to Feed tab restores DSCartBadge', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildPage());
      await tester.pump();

      await tester.tap(find.text('Reels'));
      await tester.pump();

      await tester.tap(find.text('Feed'));
      await tester.pump();

      expect(find.byType(DSCartBadge), findsOneWidget);
    });
  });
}
