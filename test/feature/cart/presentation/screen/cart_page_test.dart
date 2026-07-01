import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/app/cart/cart_cubit.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/core/components/app_error_widget.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/domain/cart/cart_repository.dart';
import 'package:klozy/src/domain/cart/entity/cart.dart';
import 'package:klozy/src/domain/cart/entity/cart_bucket.dart';
import 'package:klozy/src/domain/cart/entity/cart_item.dart';
import 'package:klozy/src/domain/offers/offers_repository.dart';
import 'package:klozy/src/feature/cart/presentation/bloc/cart_bloc.dart';
import 'package:klozy/src/feature/cart/presentation/bloc/cart_state.dart';
import 'package:klozy/src/feature/cart/presentation/screen/cart_page.dart';
import 'package:klozy/src/feature/cart/presentation/widget/cart_bucket_card_widget.dart';
import 'package:mocktail/mocktail.dart';

class _MockCartRepository extends Mock implements CartRepository {}

class _MockOffersRepository extends Mock implements OffersRepository {}

class _MockCartCubit extends Mock implements CartCubit {}

class _MockStackRouter extends Mock implements StackRouter {}

/// Minimal CartBloc that starts in [initialState] without I/O.
class _FakeCartBloc extends CartBloc {
  _FakeCartBloc(CartState initialState)
    : super(_MockCartRepository(), _MockOffersRepository(), _MockCartCubit()) {
    emit(initialState);
  }
}

Widget _wrap(CartState state, StackRouter router) {
  return BlocProvider<CartBloc>.value(
    value: _FakeCartBloc(state),
    child: MaterialApp(
      theme: dsTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: StackRouterScope(
        controller: router,
        stateHash: 0,
        child: const CartPage(),
      ),
    ),
  );
}

const _kItem = CartItem(
  productId: 'p1',
  title: 'Test Product',
  price: 100,
  brand: 'Brand',
  size: 'M',
);

const _kBucket = CartBucket(
  sellerId: 'seller1',
  sellerName: 'Test Seller',
  items: <CartItem>[_kItem],
  subtotal: 100,
);

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('CartPage', () {
    late _MockStackRouter router;

    setUp(() {
      router = _MockStackRouter();
      when(() => router.maybePop<Object?>()).thenAnswer((_) async => true);
    });

    testWidgets('shows DSLoader in loading state', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const CartLoadingState(), router));
      await tester.pump();
      expect(find.byType(DSLoader), findsOneWidget);
    });

    testWidgets('shows AppErrorWidget in error state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const CartErrorState(type: AppErrorType.network), router),
      );
      await tester.pump();
      expect(find.byType(AppErrorWidget), findsOneWidget);
    });

    testWidgets('shows empty state when cart is empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(const CartLoadedState(Cart.empty), router));
      await tester.pump();
      expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
      expect(find.byType(CartBucketCardWidget), findsNothing);
    });

    testWidgets('shows CartBucketCardWidget for each bucket when loaded', (
      WidgetTester tester,
    ) async {
      const cart = Cart(buckets: <CartBucket>[_kBucket]);
      await tester.pumpWidget(_wrap(const CartLoadedState(cart), router));
      await tester.pump();
      expect(find.byType(CartBucketCardWidget), findsOneWidget);
    });

    testWidgets('shows multiple CartBucketCardWidgets for multiple buckets', (
      WidgetTester tester,
    ) async {
      const cart = Cart(
        buckets: <CartBucket>[
          _kBucket,
          CartBucket(
            sellerId: 'seller2',
            sellerName: 'Second Seller',
            items: <CartItem>[_kItem],
            subtotal: 50,
          ),
        ],
      );
      await tester.pumpWidget(_wrap(const CartLoadedState(cart), router));
      await tester.pump();
      expect(find.byType(CartBucketCardWidget), findsNWidgets(2));
    });

    testWidgets('back button calls router.maybePop', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(const CartLoadedState(Cart.empty), router));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      verify(() => router.maybePop<Object?>()).called(1);
    });
  });
}
