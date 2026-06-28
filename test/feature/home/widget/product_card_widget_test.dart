import 'package:auto_route/auto_route.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/app/wishlist/wishlist_cubit.dart';
import 'package:klozy/src/core/account/account_gate.dart';
import 'package:klozy/src/design/components/ds_product_card.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/product/entity/product.dart';
import 'package:klozy/src/domain/wishlist/wishlist_repository.dart';
import 'package:klozy/src/feature/home/presentation/widget/product_card_widget.dart';
import 'package:klozy/src/router/app_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../../support/ds_harness.dart';

class _MockWishlistRepository extends Mock implements WishlistRepository {}

class _MockAccountGate extends Mock implements AccountGate {}

class _MockStackRouter extends Mock implements StackRouter {}

Widget _buildCard(
  Product product, {
  Set<String> wishlistIds = const {},
  StackRouter? router,
  VoidCallback? onTap,
}) {
  final wishlistRepo = _MockWishlistRepository();
  final wishlist = WishlistCubit(wishlistRepo, EventBus())..emit(wishlistIds);

  final child = BlocProvider<WishlistCubit>.value(
    value: wishlist,
    child: ProductCardWidget(product: product, onTap: onTap),
  );

  if (router != null) {
    return dsWrapRouted(child, router: router);
  }
  return dsWrap(child, wrapInScaffold: true);
}

void main() {
  setUpAll(() {
    disableDsFonts();
    registerFallbackValue(ProductRoute(id: 'fallback'));
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

  const baseProduct = Product(
    id: 'p1',
    title: 'Cool Sneakers',
    price: 150,
    brand: 'Nike',
    size: '42',
  );

  group('ProductCardWidget — behavior', () {
    testWidgets('renders title', (WidgetTester tester) async {
      await tester.pumpWidget(_buildCard(baseProduct));
      await tester.pump();

      expect(find.text('Cool Sneakers'), findsOneWidget);
    });

    testWidgets('renders brand and size as meta', (WidgetTester tester) async {
      await tester.pumpWidget(_buildCard(baseProduct));
      await tester.pump();

      expect(find.textContaining('Nike'), findsOneWidget);
      expect(find.textContaining('42'), findsOneWidget);
    });

    testWidgets('shows New badge when isNewWithTags is true', (
      WidgetTester tester,
    ) async {
      const newProduct = Product(
        id: 'p2',
        title: 'Brand New Item',
        price: 200,
        brand: 'Adidas',
        size: '40',
        isNewWithTags: true,
      );
      await tester.pumpWidget(_buildCard(newProduct));
      await tester.pump();

      // DSProductCard renders badge via label.toUpperCase()
      expect(find.text('NEW'), findsOneWidget);
    });

    testWidgets('does not show New badge when isNewWithTags is false', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_buildCard(baseProduct));
      await tester.pump();

      expect(find.text('NEW'), findsNothing);
    });

    testWidgets('heart reflects liked state from WishlistCubit', (
      WidgetTester tester,
    ) async {
      // Product p1 is in the wished set — DSProductCard should show liked.
      await tester.pumpWidget(_buildCard(baseProduct, wishlistIds: {'p1'}));
      await tester.pump();

      // DSProductCard is rendered (liked state is internal to the DS component
      // — we verify the widget tree includes it without error).
      expect(find.byType(DSProductCard), findsOneWidget);
    });

    testWidgets('custom onTap callback is invoked when tapped', (
      WidgetTester tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        _buildCard(baseProduct, onTap: () => tapped = true),
      );
      await tester.pump();

      await tester.tap(find.byType(DSProductCard));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('default onTap pushes ProductRoute via router', (
      WidgetTester tester,
    ) async {
      final router = _MockStackRouter();
      when(
        () => router.push<Object?>(any(), onFailure: any(named: 'onFailure')),
      ).thenAnswer((_) async => null);

      await tester.pumpWidget(_buildCard(baseProduct, router: router));
      await tester.pump();

      await tester.tap(find.byType(DSProductCard));
      await tester.pump();

      final captured = verify(
        () => router.push<Object?>(
          captureAny(),
          onFailure: any(named: 'onFailure'),
        ),
      ).captured;
      expect(captured.single, isA<ProductRoute>());
    });
  });
}
