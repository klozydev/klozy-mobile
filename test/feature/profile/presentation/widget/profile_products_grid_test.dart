import 'package:auto_route/auto_route.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/app/wishlist/wishlist_cubit.dart';
import 'package:klozy/src/core/account/account_gate.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/product/entity/product.dart';
import 'package:klozy/src/domain/wishlist/wishlist_repository.dart';
import 'package:klozy/src/feature/profile/presentation/widget/profile_products_grid.dart';
import 'package:klozy/src/feature/profile/presentation/widget/profile_tab_empty.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../support/ds_harness.dart';

class _MockWishlistRepository extends Mock implements WishlistRepository {}

class _MockAccountGate extends Mock implements AccountGate {}

class _FakeRoute extends Fake implements PageRouteInfo<Object?> {}

// Wraps the widget with WishlistCubit provided so ProductCardWidget works.
Widget _wrapWithWishlist(Widget child) {
  final wishlistCubit = WishlistCubit(_MockWishlistRepository(), EventBus());
  return BlocProvider<WishlistCubit>.value(
    value: wishlistCubit,
    child: dsWrap(child, wrapInScaffold: true),
  );
}

void main() {
  setUpAll(() {
    disableDsFonts();
    registerFallbackValue(_FakeRoute());
  });

  late _MockAccountGate mockAccountGate;

  setUp(() {
    mockAccountGate = _MockAccountGate();
    if (!locator.isRegistered<AccountGate>()) {
      locator.registerSingleton<AccountGate>(mockAccountGate);
    }
  });

  tearDown(() {
    if (locator.isRegistered<AccountGate>()) {
      locator.unregister<AccountGate>();
    }
  });

  testWidgets('shows ProfileTabEmpty when products list is empty', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrapWithWishlist(const ProfileProductsGrid(products: [])),
    );
    await tester.pump();
    expect(find.byType(ProfileTabEmpty), findsOneWidget);
    expect(find.text('No listings yet'), findsOneWidget);
  });

  testWidgets('shows GridView when products are present', (
    WidgetTester tester,
  ) async {
    const products = <Product>[
      Product(id: 'p1', title: 'Blue Jacket', price: 29),
      Product(id: 'p2', title: 'Red Dress', price: 45),
    ];
    await tester.pumpWidget(
      _wrapWithWishlist(const ProfileProductsGrid(products: products)),
    );
    await tester.pump();
    expect(find.byType(ProfileTabEmpty), findsNothing);
    expect(find.byType(GridView), findsOneWidget);
  });
}
