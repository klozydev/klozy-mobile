import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/core/components/app_error_widget.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/domain/orders/entity/order_action.dart';
import 'package:klozy/src/domain/orders/entity/order_list_item.dart';
import 'package:klozy/src/domain/orders/entity/order_status.dart';
import 'package:klozy/src/domain/orders/orders_repository.dart';
import 'package:klozy/src/feature/orders/presentation/bloc/orders_bloc.dart';
import 'package:klozy/src/feature/orders/presentation/bloc/orders_state.dart';
import 'package:klozy/src/feature/orders/presentation/screen/orders_page.dart';
import 'package:klozy/src/feature/orders/presentation/widget/order_list_card_widget.dart';
import 'package:klozy/src/router/app_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../../support/ds_harness.dart';

class _MockOrdersRepository extends Mock implements OrdersRepository {}

class _MockStackRouter extends Mock implements StackRouter {}

/// Drives the bloc into a specific initial state without touching the repo.
class _FakeOrdersBloc extends OrdersBloc {
  _FakeOrdersBloc(OrdersState initialState) : super(_MockOrdersRepository()) {
    emit(initialState);
  }
}

Widget _wrap(OrdersState state, StackRouter router) {
  return BlocProvider<OrdersBloc>.value(
    value: _FakeOrdersBloc(state),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: dsTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: StackRouterScope(
        controller: router,
        stateHash: 0,
        child: const OrdersPage(),
      ),
    ),
  );
}

const _kItem = OrderListItem(
  id: 'o1',
  title: 'Cool Sneakers',
  price: 200,
  status: OrderStatus.pending,
  counterpartName: 'Alice',
);

void main() {
  setUpAll(() {
    disableDsFonts();
    registerFallbackValue(OrderDetailRoute(id: ''));
  });

  late _MockStackRouter router;

  setUp(() {
    router = _MockStackRouter();
    when(
      () => router.push<Object?>(any(), onFailure: any(named: 'onFailure')),
    ).thenAnswer((_) async => null);
  });

  group('OrdersPage', () {
    testWidgets('loading state renders DSLoader', (tester) async {
      await tester.pumpWidget(_wrap(const OrdersLoadingState(), router));
      await tester.pump();
      expect(find.byType(DSLoader), findsOneWidget);
    });

    testWidgets('error state renders AppErrorWidget', (tester) async {
      await tester.pumpWidget(
        _wrap(const OrdersErrorState(type: AppErrorType.network), router),
      );
      await tester.pump();
      expect(find.byType(AppErrorWidget), findsOneWidget);
    });

    testWidgets('empty loaded state shows no-orders message', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const OrdersLoadedState(
            role: OrderRole.buyer,
            inProgress: <OrderListItem>[],
            completed: <OrderListItem>[],
          ),
          router,
        ),
      );
      await tester.pump();
      expect(find.text('No orders yet'), findsOneWidget);
    });

    testWidgets('loaded with in-progress orders renders OrderListCardWidget', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const OrdersLoadedState(
            role: OrderRole.buyer,
            inProgress: <OrderListItem>[_kItem],
            completed: <OrderListItem>[],
          ),
          router,
        ),
      );
      await tester.pump();
      expect(find.byType(OrderListCardWidget), findsOneWidget);
      expect(find.text('Cool Sneakers'), findsOneWidget);
    });

    testWidgets('loaded with two orders renders two cards', (tester) async {
      const second = OrderListItem(
        id: 'o2',
        title: 'Leather Jacket',
        price: 500,
        status: OrderStatus.completed,
      );
      await tester.pumpWidget(
        _wrap(
          const OrdersLoadedState(
            role: OrderRole.buyer,
            inProgress: <OrderListItem>[_kItem],
            completed: <OrderListItem>[second],
          ),
          router,
        ),
      );
      await tester.pump();
      expect(find.byType(OrderListCardWidget), findsNWidgets(2));
    });

    testWidgets('loaded shows "Buying" tab label in segmented control', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const OrdersLoadedState(
            role: OrderRole.buyer,
            inProgress: <OrderListItem>[],
            completed: <OrderListItem>[],
          ),
          router,
        ),
      );
      await tester.pump();
      expect(find.text('Buying'), findsOneWidget);
      expect(find.text('Selling'), findsOneWidget);
    });

    testWidgets('tapping a card pushes OrderDetailRoute', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const OrdersLoadedState(
            role: OrderRole.buyer,
            inProgress: <OrderListItem>[_kItem],
            completed: <OrderListItem>[],
          ),
          router,
        ),
      );
      await tester.pump();
      await tester.tap(find.byType(OrderListCardWidget));
      await tester.pump();
      final captured = verify(
        () => router.push<Object?>(
          captureAny(),
          onFailure: any(named: 'onFailure'),
        ),
      ).captured;
      expect(captured.single, isA<OrderDetailRoute>());
    });
  });
}
