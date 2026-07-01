import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/app/wishlist/wishlist_cubit.dart';
import 'package:klozy/src/core/account/account_gate.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/design/components/shimmer_box/shimmer_box_widget.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/catalog/catalog_repository.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_category.dart';
import 'package:klozy/src/domain/product/entity/product.dart';
import 'package:klozy/src/domain/product/products_repository.dart';
import 'package:klozy/src/domain/wishlist/wishlist_repository.dart';
import 'package:klozy/src/feature/home/presentation/bloc/feed_bloc.dart';
import 'package:klozy/src/feature/home/presentation/bloc/feed_state.dart';
import 'package:klozy/src/feature/home/presentation/widget/feed_tab_widget.dart';
import 'package:mocktail/mocktail.dart';

import '../../../support/ds_harness.dart';

class _MockProductsRepository extends Mock implements ProductsRepository {}

class _MockCatalogRepository extends Mock implements CatalogRepository {}

class _MockWishlistRepository extends Mock implements WishlistRepository {}

class _MockAccountGate extends Mock implements AccountGate {}

/// Extends FeedBloc and overrides `state` / `stream` so the widget always
/// sees a fixed state without any async transitions. Events are still
/// registered but repos are never called (no event is dispatched).
class _FixedStateFeedBloc extends FeedBloc {
  final FeedState _fixed;

  _FixedStateFeedBloc(this._fixed)
    : super(_MockProductsRepository(), _MockCatalogRepository(), EventBus());

  @override
  FeedState get state => _fixed;

  @override
  Stream<FeedState> get stream => Stream.value(_fixed);
}

Widget _buildTab(FeedState state) {
  final bloc = _FixedStateFeedBloc(state);
  final wishlistCubit = WishlistCubit(_MockWishlistRepository(), EventBus());

  return dsWrap(
    MultiBlocProvider(
      providers: [
        BlocProvider<FeedBloc>.value(value: bloc),
        BlocProvider<WishlistCubit>.value(value: wishlistCubit),
      ],
      child: const FeedTabWidget(),
    ),
  );
}

void main() {
  setUpAll(() {
    disableDsFonts();
  });

  late _MockAccountGate mockAccountGate;

  setUp(() {
    mockAccountGate = _MockAccountGate();
    if (locator.isRegistered<AccountGate>()) {
      locator.unregister<AccountGate>();
    }
    locator.registerSingleton<AccountGate>(mockAccountGate);
  });

  tearDown(() {
    if (locator.isRegistered<AccountGate>()) {
      locator.unregister<AccountGate>();
    }
  });

  group('FeedTabWidget', () {
    testWidgets('shows shimmer grid in loading state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_buildTab(const FeedLoading()));
      // One frame to build; the ShimmerBoxWidget's Future.delayed(zero) has
      // NOT fired yet — shimmer is in tree but animation hasn't started.
      expect(find.byType(ShimmerBoxWidget), findsWidgets);

      // Advance fake time past Duration.zero to flush the delayed future and
      // let the animation start, then replace the tree so dispose() cancels it.
      await tester.pump(Duration.zero);
      await tester.pumpWidget(const SizedBox.shrink()); // unmount → dispose
    });

    testWidgets('shows product cards when FeedReady has items', (
      WidgetTester tester,
    ) async {
      const state = FeedReady(
        categories: [],
        items: [
          Product(id: 'p1', title: 'Sneakers', price: 100),
          Product(id: 'p2', title: 'Jacket', price: 200),
        ],
      );

      await tester.pumpWidget(_buildTab(state));
      await tester.pump();

      expect(find.text('Sneakers'), findsOneWidget);
      expect(find.text('Jacket'), findsOneWidget);
    });

    testWidgets('shows empty message when FeedReady has no items', (
      WidgetTester tester,
    ) async {
      const state = FeedReady(categories: [], items: []);

      await tester.pumpWidget(_buildTab(state));
      await tester.pump();

      expect(find.text('Nothing here yet.'), findsOneWidget);
    });

    testWidgets('shows error title when FeedError', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_buildTab(const FeedError(AppErrorType.network)));
      await tester.pump();

      // AppErrorWidget renders the error title from AppErrorType.
      expect(find.text('No connection'), findsOneWidget);
    });

    testWidgets('shows All chip plus category chips when FeedReady', (
      WidgetTester tester,
    ) async {
      const state = FeedReady(
        categories: [
          CatalogCategory(id: 'women', label: 'Women'),
          CatalogCategory(id: 'men', label: 'Men'),
        ],
        items: [],
      );

      await tester.pumpWidget(_buildTab(state));
      await tester.pump();

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Women'), findsOneWidget);
      expect(find.text('Men'), findsOneWidget);
    });

    testWidgets(
      'shows picked-for-you hint when pickedForYou is non-empty on All tab',
      (WidgetTester tester) async {
        const state = FeedReady(
          categories: [],
          items: [],
          pickedForYou: ['Women', 'Kids'],
          selectedRootId: null,
        );

        await tester.pumpWidget(_buildTab(state));
        await tester.pump();

        expect(find.textContaining('Women, Kids'), findsOneWidget);
      },
    );
  });
}
