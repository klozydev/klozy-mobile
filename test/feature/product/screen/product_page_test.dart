import 'package:auto_route/auto_route.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/app/cart/cart_cubit.dart';
import 'package:klozy/src/app/wishlist/wishlist_cubit.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/core/components/app_error_widget.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/domain/cart/cart_repository.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:klozy/src/domain/product/entity/product_detail.dart';
import 'package:klozy/src/domain/product/products_repository.dart';
import 'package:klozy/src/domain/wishlist/wishlist_repository.dart';
import 'package:klozy/src/feature/product/presentation/bloc/product_bloc.dart';
import 'package:klozy/src/feature/product/presentation/bloc/product_state.dart';
import 'package:klozy/src/feature/product/presentation/screen/product_page.dart';
import 'package:klozy/src/router/app_router.dart';
import 'package:mocktail/mocktail.dart';

class _MockProductsRepository extends Mock implements ProductsRepository {}

class _MockCartRepository extends Mock implements CartRepository {}

class _MockMeRepository extends Mock implements MeRepository {}

class _MockWishlistRepository extends Mock implements WishlistRepository {}

class _MockStackRouter extends Mock implements StackRouter {}

/// Minimal [ProductBloc] that starts in [initialState] without any I/O.
class _FakeProductBloc extends ProductBloc {
  _FakeProductBloc(ProductState initialState)
    : super(
        _MockProductsRepository(),
        _MockCartRepository(),
        _MockMeRepository(),
        _FakeCartCubit(),
      ) {
    emit(initialState);
  }
}

/// Minimal [CartCubit] that returns an empty cart.
class _FakeCartCubit extends CartCubit {
  _FakeCartCubit() : super(_MockCartRepositoryForCubit());
}

class _MockCartRepositoryForCubit extends Mock implements CartRepository {}

const _kSeller = ProductSeller(id: 's1', displayName: 'Bob');
const _kOwnerSeller = ProductSeller(id: 'me', displayName: 'Me');

const _kBuyerDetail = ProductDetail(
  id: 'p1',
  title: 'Nice Coat',
  price: 250,
  seller: _kSeller,
  isOwner: false,
);

const _kOwnerDetail = ProductDetail(
  id: 'p1',
  title: 'My Coat',
  price: 250,
  seller: _kOwnerSeller,
  isOwner: true,
);

Widget _wrap(
  ProductState state, {
  required StackRouter router,
  WishlistCubit? wishlist,
}) {
  final bloc = _FakeProductBloc(state);

  final providers = <BlocProvider>[
    BlocProvider<ProductBloc>.value(value: bloc),
    if (wishlist != null) BlocProvider<WishlistCubit>.value(value: wishlist),
  ];

  return MultiBlocProvider(
    providers: providers,
    child: MaterialApp(
      theme: dsTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: StackRouterScope(
        controller: router,
        stateHash: 0,
        child: const ProductPage(id: 'p1'),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    registerFallbackValue(const CartRoute());
    registerFallbackValue(EditListingRoute(productId: ''));
  });

  group('ProductPage', () {
    late _MockStackRouter router;
    late WishlistCubit wishlist;

    setUp(() {
      router = _MockStackRouter();
      when(
        () => router.push<Object?>(any(), onFailure: any(named: 'onFailure')),
      ).thenAnswer((_) async => null);
      when(() => router.maybePop<Object?>()).thenAnswer((_) async => true);

      wishlist = WishlistCubit(_MockWishlistRepository(), EventBus());
    });

    testWidgets('shows DSLoader in loading state', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(const ProductLoadingState(), router: router),
      );
      await tester.pump();

      expect(find.byType(DSLoader), findsOneWidget);
    });

    testWidgets('shows AppErrorWidget in error state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const ProductErrorState(type: AppErrorType.network),
          router: router,
        ),
      );
      await tester.pump();

      expect(find.byType(AppErrorWidget), findsOneWidget);
    });

    testWidgets('shows Listing deleted text in deleted state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const ProductDeletedState(), router: router),
      );
      await tester.pump();

      expect(find.text('Listing deleted'), findsOneWidget);
    });

    testWidgets('shows listing deleted subtitle in deleted state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const ProductDeletedState(), router: router),
      );
      await tester.pump();

      expect(
        find.text('This item and its photos have been removed.'),
        findsOneWidget,
      );
    });

    testWidgets('shows Edit listing CTA for owner in loaded state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const ProductLoadedState(detail: _kOwnerDetail),
          router: router,
          wishlist: wishlist,
        ),
      );
      await tester.pump();

      expect(find.text('Edit listing'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows Add to cart CTA for buyer in loaded state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const ProductLoadedState(detail: _kBuyerDetail),
          router: router,
          wishlist: wishlist,
        ),
      );
      await tester.pump();

      expect(find.text('Add to cart'), findsOneWidget);
    });

    testWidgets('shows In cart · View cart when inCart is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const ProductLoadedState(detail: _kBuyerDetail, inCart: true),
          router: router,
          wishlist: wishlist,
        ),
      );
      await tester.pump();

      expect(find.text('In cart · View cart'), findsOneWidget);
    });
  });
}
