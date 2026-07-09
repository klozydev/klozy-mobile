import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/app/wishlist/wishlist_cubit.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/design/components/ds_button_outline.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/product/entity/product.dart';
import 'package:klozy/src/domain/wishlist/wishlist_repository.dart';
import 'package:klozy/src/feature/home/presentation/bloc/wishlist_feed_cubit.dart';
import 'package:klozy/src/feature/home/presentation/bloc/wishlist_feed_state.dart';
import 'package:klozy/src/feature/home/presentation/widget/wishlist_tab_widget.dart';
import 'package:mocktail/mocktail.dart';

import '../../../support/ds_harness.dart';

class _MockWishlistRepository extends Mock implements WishlistRepository {}

/// Fully overrides load/loadMore/refresh (recording call counts) so the
/// widget under test never touches the real repository — tests drive state
/// transitions directly via [emitState].
class _FakeWishlistFeedCubit extends WishlistFeedCubit {
  int loadCalls = 0;
  int loadMoreCalls = 0;
  int refreshCalls = 0;

  _FakeWishlistFeedCubit(super.repository, super.eventBus);

  void emitState(WishlistFeedState state) => emit(state);

  @override
  Future<void> load() async {
    loadCalls++;
  }

  @override
  Future<void> loadMore() async {
    loadMoreCalls++;
  }

  @override
  Future<void> refresh() async {
    refreshCalls++;
  }
}

Widget _buildTab({
  required WishlistFeedCubit feedCubit,
  required WishlistCubit wishlistCubit,
  bool active = true,
}) {
  if (locator.isRegistered<WishlistFeedCubit>()) {
    locator.unregister<WishlistFeedCubit>();
  }
  locator.registerFactory<WishlistFeedCubit>(() => feedCubit);

  return dsWrap(
    BlocProvider<WishlistCubit>.value(
      value: wishlistCubit,
      child: WishlistTabWidget(active: active),
    ),
  );
}

void main() {
  setUpAll(() {
    disableDsFonts();
  });

  late _MockWishlistRepository mockRepo;
  late EventBus eventBus;
  late _FakeWishlistFeedCubit fakeFeedCubit;
  late WishlistCubit wishlistCubit;

  setUp(() {
    mockRepo = _MockWishlistRepository();
    eventBus = EventBus();
    fakeFeedCubit = _FakeWishlistFeedCubit(mockRepo, eventBus);
    wishlistCubit = WishlistCubit(mockRepo, eventBus);
  });

  tearDown(() {
    if (locator.isRegistered<WishlistFeedCubit>()) {
      locator.unregister<WishlistFeedCubit>();
    }
    fakeFeedCubit.close();
    wishlistCubit.close();
  });

  group('WishlistTabWidget', () {
    testWidgets(
      'shows loader in the initial (loading) state and calls load()',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          _buildTab(feedCubit: fakeFeedCubit, wishlistCubit: wishlistCubit),
        );
        await tester.pump();

        expect(find.byType(DSLoader), findsOneWidget);
        expect(fakeFeedCubit.loadCalls, 1);
      },
    );

    testWidgets(
      'shows empty state (still scrollable) when loaded with no items',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          _buildTab(feedCubit: fakeFeedCubit, wishlistCubit: wishlistCubit),
        );
        fakeFeedCubit.emitState(const WishlistFeedLoaded(items: <Product>[]));
        await tester.pump();

        expect(find.text('Your wishlist is empty'), findsOneWidget);
        expect(
          find.text('Tap the heart on any item to save it here.'),
          findsOneWidget,
        );
        // Wrapped in a scrollable so RefreshIndicator still works when empty.
        expect(find.byType(CustomScrollView), findsOneWidget);
      },
    );

    testWidgets('filters items against the live WishlistCubit id-set', (
      WidgetTester tester,
    ) async {
      const products = [
        Product(id: 'p1', title: 'Sneakers', price: 100),
        Product(id: 'p2', title: 'Jacket', price: 200),
      ];
      wishlistCubit.emit(const {'p1'});

      await tester.pumpWidget(
        _buildTab(feedCubit: fakeFeedCubit, wishlistCubit: wishlistCubit),
      );
      fakeFeedCubit.emitState(const WishlistFeedLoaded(items: products));
      await tester.pump();

      expect(find.text('Sneakers'), findsOneWidget);
      expect(find.text('Jacket'), findsNothing);
    });

    testWidgets('shows saved-count header reflecting the filtered count', (
      WidgetTester tester,
    ) async {
      const products = [
        Product(id: 'p1', title: 'Sneakers', price: 100),
        Product(id: 'p2', title: 'Jacket', price: 200),
      ];
      wishlistCubit.emit(const {'p1'});

      await tester.pumpWidget(
        _buildTab(feedCubit: fakeFeedCubit, wishlistCubit: wishlistCubit),
      );
      fakeFeedCubit.emitState(const WishlistFeedLoaded(items: products));
      await tester.pump();

      expect(find.text('1 saved item'), findsOneWidget);
    });

    testWidgets('shows AppErrorWidget on error and retry calls load()', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _buildTab(feedCubit: fakeFeedCubit, wishlistCubit: wishlistCubit),
      );
      fakeFeedCubit.emitState(const WishlistFeedError(AppErrorType.network));
      await tester.pump();

      expect(find.text('No connection'), findsOneWidget);

      final int loadCallsBefore = fakeFeedCubit.loadCalls;
      await tester.tap(find.byType(DSButtonOutline));
      await tester.pump();

      expect(fakeFeedCubit.loadCalls, loadCallsBefore + 1);
    });

    testWidgets('shows the bottom loader sliver while loadingMore is true', (
      WidgetTester tester,
    ) async {
      const products = [Product(id: 'p1', title: 'Sneakers', price: 100)];
      wishlistCubit.emit(const {'p1'});

      await tester.pumpWidget(
        _buildTab(feedCubit: fakeFeedCubit, wishlistCubit: wishlistCubit),
      );
      fakeFeedCubit.emitState(
        const WishlistFeedLoaded(
          items: products,
          hasMore: true,
          loadingMore: true,
        ),
      );
      await tester.pump();

      // A single tall grid card can push the bottom loader sliver past the
      // default viewport + cache extent, so it isn't mounted until scrolled
      // into view — scroll down first, as a user nearing the end would.
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -2000));
      await tester.pump();

      expect(find.byType(DSLoader), findsOneWidget);
    });

    testWidgets('pull-to-refresh calls cubit.refresh()', (
      WidgetTester tester,
    ) async {
      const products = [Product(id: 'p1', title: 'Sneakers', price: 100)];
      wishlistCubit.emit(const {'p1'});

      await tester.pumpWidget(
        _buildTab(feedCubit: fakeFeedCubit, wishlistCubit: wishlistCubit),
      );
      fakeFeedCubit.emitState(const WishlistFeedLoaded(items: products));
      await tester.pump();

      // Fire-and-forget: `show()`'s Future only resolves once the
      // indicator's own show/hide animation completes, which needs real
      // frame pumps (a bare `await` on it hangs forever in the fake-clock
      // test zone). `pumpAndSettle` drives both the animation and the
      // synchronous `onRefresh` call to completion.
      unawaited(
        tester
            .state<RefreshIndicatorState>(find.byType(RefreshIndicator))
            .show(),
      );
      await tester.pumpAndSettle();

      expect(fakeFeedCubit.refreshCalls, 1);
    });

    testWidgets('scroll-end triggers loadMore() when hasMore is true', (
      WidgetTester tester,
    ) async {
      final List<Product> products = List<Product>.generate(
        20,
        (int i) => Product(id: 'p$i', title: 'Product $i', price: 100),
      );
      wishlistCubit.emit(products.map((Product p) => p.id).toSet());

      await tester.pumpWidget(
        _buildTab(feedCubit: fakeFeedCubit, wishlistCubit: wishlistCubit),
      );
      fakeFeedCubit.emitState(
        WishlistFeedLoaded(items: products, hasMore: true),
      );
      await tester.pump();

      // Oversized drag: physics clamps at maxScrollExtent, so this reliably
      // lands within the load-more threshold regardless of grid card size.
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -20000));
      await tester.pump();

      expect(fakeFeedCubit.loadMoreCalls, greaterThanOrEqualTo(1));
    });

    testWidgets(
      'does not call loadMore() when hasMore is false, even near the bottom',
      (WidgetTester tester) async {
        final List<Product> products = List<Product>.generate(
          20,
          (int i) => Product(id: 'p$i', title: 'Product $i', price: 100),
        );
        wishlistCubit.emit(products.map((Product p) => p.id).toSet());

        await tester.pumpWidget(
          _buildTab(feedCubit: fakeFeedCubit, wishlistCubit: wishlistCubit),
        );
        fakeFeedCubit.emitState(
          WishlistFeedLoaded(items: products, hasMore: false),
        );
        await tester.pump();

        await tester.drag(
          find.byType(CustomScrollView),
          const Offset(0, -4000),
        );
        await tester.pump();

        expect(fakeFeedCubit.loadMoreCalls, 0);
      },
    );

    testWidgets('becoming active calls refresh() via didUpdateWidget', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _buildTab(
          feedCubit: fakeFeedCubit,
          wishlistCubit: wishlistCubit,
          active: false,
        ),
      );
      await tester.pump();
      expect(fakeFeedCubit.refreshCalls, 0);

      await tester.pumpWidget(
        _buildTab(
          feedCubit: fakeFeedCubit,
          wishlistCubit: wishlistCubit,
          active: true,
        ),
      );
      await tester.pump();

      expect(fakeFeedCubit.refreshCalls, 1);
    });
  });
}
