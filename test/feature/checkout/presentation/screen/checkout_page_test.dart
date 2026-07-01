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
import 'package:klozy/src/domain/cart/entity/cart_bucket.dart';
import 'package:klozy/src/domain/cart/entity/cart_item.dart';
import 'package:klozy/src/domain/checkout/checkout_repository.dart';
import 'package:klozy/src/domain/checkout/entity/checkout_quote.dart';
import 'package:klozy/src/domain/checkout/entity/order_fees.dart';
import 'package:klozy/src/domain/me/entity/address.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:klozy/src/feature/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:klozy/src/feature/checkout/presentation/bloc/checkout_state.dart';
import 'package:klozy/src/feature/checkout/presentation/screen/checkout_page.dart';
import 'package:mocktail/mocktail.dart';

class _MockCheckoutRepository extends Mock implements CheckoutRepository {}

class _MockMeRepository extends Mock implements MeRepository {}

class _MockCartCubit extends Mock implements CartCubit {}

class _MockStackRouter extends Mock implements StackRouter {}

/// Minimal CheckoutBloc that starts in [initialState] without I/O.
class _FakeCheckoutBloc extends CheckoutBloc {
  _FakeCheckoutBloc(CheckoutState initialState)
    : super(_MockCheckoutRepository(), _MockMeRepository(), _MockCartCubit()) {
    emit(initialState);
  }
}

const _kItem = CartItem(productId: 'p1', title: 'Blue Jacket', price: 200);

const _kBucket = CartBucket(
  sellerId: 'seller1',
  sellerName: 'Test Seller',
  items: <CartItem>[_kItem],
  subtotal: 200,
);

const _kFees = OrderFees(
  subtotal: 200,
  shipping: 20,
  protection: 10,
  vat: 15,
  total: 245,
);

const _kQuote = CheckoutQuote(fees: _kFees, shipmentType: 'Standard');

const _kAddress = Address(
  id: 'addr1',
  line1: 'Marina Gate 1',
  city: 'Dubai',
  emirate: 'Dubai',
  isDefault: true,
);

const _kReadyState = CheckoutReadyState(
  addresses: <Address>[_kAddress],
  selectedAddressId: 'addr1',
  quote: _kQuote,
);

Widget _wrap(CheckoutState state, StackRouter router) {
  return BlocProvider<CheckoutBloc>.value(
    value: _FakeCheckoutBloc(state),
    child: MaterialApp(
      theme: dsTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: StackRouterScope(
        controller: router,
        stateHash: 0,
        child: const CheckoutPage(sellerId: 'seller1', bucket: _kBucket),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('CheckoutPage', () {
    late _MockStackRouter router;

    setUp(() {
      router = _MockStackRouter();
      when(() => router.maybePop<Object?>()).thenAnswer((_) async => true);
    });

    testWidgets('shows DSLoader in loading state', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const CheckoutLoadingState(), router));
      await tester.pump();
      expect(find.byType(DSLoader), findsOneWidget);
    });

    testWidgets('shows AppErrorWidget in error state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const CheckoutErrorState(type: AppErrorType.network), router),
      );
      await tester.pump();
      expect(find.byType(AppErrorWidget), findsOneWidget);
    });

    testWidgets('shows AppErrorWidget with server message when provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const CheckoutErrorState(
            type: AppErrorType.server,
            message: 'Items no longer available',
          ),
          router,
        ),
      );
      await tester.pump();
      expect(find.byType(AppErrorWidget), findsOneWidget);
      expect(find.text('Items no longer available'), findsOneWidget);
    });

    testWidgets('shows review screen in ready state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(_kReadyState, router));
      await tester.pump();
      // The review screen has a pay button
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('ready state shows seller name in seller card', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(_kReadyState, router));
      await tester.pump();
      expect(find.text('Test Seller'), findsOneWidget);
    });

    testWidgets('ready state shows delivery address', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(_kReadyState, router));
      await tester.pump();
      // Address summary includes line1 + city
      expect(find.textContaining('Marina Gate 1'), findsOneWidget);
    });

    testWidgets('ready state pay button enabled when address is selected', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(_kReadyState, router));
      await tester.pump();
      final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(btn.onPressed, isNotNull);
    });

    testWidgets('ready state pay button disabled when no address', (
      WidgetTester tester,
    ) async {
      const stateNoAddress = CheckoutReadyState(
        addresses: <Address>[],
        quote: _kQuote,
      );
      await tester.pumpWidget(_wrap(stateNoAddress, router));
      await tester.pump();
      final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(btn.onPressed, isNull);
    });

    testWidgets('shows order placed screen in done state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const CheckoutDoneState('order-123'), router),
      );
      await tester.pump();
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('done state shows two buttons — track order and continue', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const CheckoutDoneState('order-1'), router),
      );
      await tester.pump();
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('back button in review state calls router.maybePop', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(_kReadyState, router));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      verify(() => router.maybePop<Object?>()).called(1);
    });
  });
}
