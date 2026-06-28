import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/core/components/app_error_widget.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/domain/cart/entity/cart_item.dart';
import 'package:klozy/src/domain/orders/entity/order.dart';
import 'package:klozy/src/domain/orders/entity/order_action.dart';
import 'package:klozy/src/domain/orders/entity/order_status.dart';
import 'package:klozy/src/domain/orders/entity/order_tracking.dart';
import 'package:klozy/src/domain/orders/orders_repository.dart';
import 'package:klozy/src/domain/product/entity/product_detail.dart';
import 'package:klozy/src/feature/orders/presentation/bloc/order_detail_bloc.dart';
import 'package:klozy/src/feature/orders/presentation/bloc/order_detail_state.dart';
import 'package:klozy/src/feature/orders/presentation/screen/order_detail_page.dart';
import 'package:klozy/src/feature/orders/presentation/widget/order_counterpart_card_widget.dart';
import 'package:klozy/src/feature/orders/presentation/widget/order_status_pill_widget.dart';
import 'package:klozy/src/feature/orders/presentation/widget/order_tracking_stepper_widget.dart';
import 'package:mocktail/mocktail.dart';

import '../../../support/ds_harness.dart';

class _MockOrdersRepository extends Mock implements OrdersRepository {}

class _MockStackRouter extends Mock implements StackRouter {}

class _FakeOrderDetailBloc extends OrderDetailBloc {
  _FakeOrderDetailBloc(OrderDetailState initialState)
    : super(_MockOrdersRepository()) {
    emit(initialState);
  }
}

const _kSeller = ProductSeller(id: 'seller-1', displayName: 'John Doe');

const _kOrder = Order(
  id: 'order-1',
  status: OrderStatus.pending,
  viewerRole: OrderRole.buyer,
  counterpart: _kSeller,
);

const _kOrderWithItem = Order(
  id: 'order-2',
  status: OrderStatus.inDelivery,
  viewerRole: OrderRole.buyer,
  counterpart: _kSeller,
  items: <CartItem>[CartItem(productId: 'p1', title: 'Sneakers', price: 150)],
);

Widget _wrap(OrderDetailState state, StackRouter router) {
  return BlocProvider<OrderDetailBloc>.value(
    value: _FakeOrderDetailBloc(state),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: dsTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: StackRouterScope(
        controller: router,
        stateHash: 0,
        child: const OrderDetailPage(id: 'order-1'),
      ),
    ),
  );
}

void main() {
  setUpAll(disableDsFonts);

  late _MockStackRouter router;

  setUp(() {
    router = _MockStackRouter();
    when(() => router.maybePop<Object?>()).thenAnswer((_) async => true);
  });

  group('OrderDetailPage', () {
    testWidgets('loading state renders DSLoader', (tester) async {
      await tester.pumpWidget(_wrap(const OrderDetailLoadingState(), router));
      await tester.pump();
      expect(find.byType(DSLoader), findsOneWidget);
    });

    testWidgets('error state renders AppErrorWidget', (tester) async {
      await tester.pumpWidget(
        _wrap(const OrderDetailErrorState(type: AppErrorType.network), router),
      );
      await tester.pump();
      expect(find.byType(AppErrorWidget), findsOneWidget);
    });

    testWidgets('loaded state shows order details app bar title', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const OrderDetailLoadedState(_kOrder), router),
      );
      await tester.pump();
      expect(find.text('Order details'), findsOneWidget);
    });

    testWidgets('loaded state renders OrderStatusPillWidget', (tester) async {
      await tester.pumpWidget(
        _wrap(const OrderDetailLoadedState(_kOrder), router),
      );
      await tester.pump();
      expect(find.byType(OrderStatusPillWidget), findsOneWidget);
    });

    testWidgets('loaded state renders OrderTrackingStepperWidget', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const OrderDetailLoadedState(_kOrder), router),
      );
      await tester.pump();
      expect(find.byType(OrderTrackingStepperWidget), findsOneWidget);
    });

    testWidgets('loaded state renders OrderCounterpartCardWidget', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const OrderDetailLoadedState(_kOrder), router),
      );
      await tester.pump();
      expect(find.byType(OrderCounterpartCardWidget), findsOneWidget);
    });

    testWidgets('loaded state shows counterpart display name', (tester) async {
      await tester.pumpWidget(
        _wrap(const OrderDetailLoadedState(_kOrder), router),
      );
      await tester.pump();
      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('loaded state shows cart item title', (tester) async {
      await tester.pumpWidget(
        _wrap(const OrderDetailLoadedState(_kOrderWithItem), router),
      );
      await tester.pump();
      expect(find.text('Sneakers'), findsOneWidget);
    });

    testWidgets('loaded with tracking number shows it', (tester) async {
      const orderWithTracking = Order(
        id: 'order-3',
        status: OrderStatus.inDelivery,
        viewerRole: OrderRole.buyer,
        counterpart: _kSeller,
        tracking: OrderTracking(trackingNumber: 'EMX-9999'),
      );
      await tester.pumpWidget(
        _wrap(const OrderDetailLoadedState(orderWithTracking), router),
      );
      await tester.pump();
      expect(find.text('EMX-9999'), findsOneWidget);
    });

    testWidgets('loaded with delivery address shows it', (tester) async {
      const orderWithAddress = Order(
        id: 'order-4',
        status: OrderStatus.inDelivery,
        viewerRole: OrderRole.buyer,
        counterpart: _kSeller,
        deliveryAddress: '123 Main St, Dubai',
      );
      await tester.pumpWidget(
        _wrap(const OrderDetailLoadedState(orderWithAddress), router),
      );
      await tester.pump();
      expect(find.text('123 Main St, Dubai'), findsOneWidget);
    });

    testWidgets('back button calls router.maybePop', (tester) async {
      await tester.pumpWidget(
        _wrap(const OrderDetailLoadedState(_kOrder), router),
      );
      await tester.pump();
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      verify(() => router.maybePop<Object?>()).called(1);
    });
  });
}
