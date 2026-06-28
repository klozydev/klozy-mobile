import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/domain/product/entity/product_detail.dart';
import 'package:klozy/src/feature/product/presentation/widget/product_cta_bar_widget.dart';

import '../../../support/ds_harness.dart';

const _kSeller = ProductSeller(id: 's1', displayName: 'Seller');

ProductDetail _detail({
  bool isOwner = false,
  ProductStatus status = ProductStatus.active,
}) => ProductDetail(
  id: 'p1',
  title: 'Test Item',
  price: 100,
  seller: _kSeller,
  isOwner: isOwner,
  status: status,
);

Widget _wrap({
  required ProductDetail detail,
  bool inCart = false,
  VoidCallback? onAddToCart,
  VoidCallback? onViewCart,
  VoidCallback? onEdit,
  VoidCallback? onOpenMenu,
}) {
  return dsWrap(
    ProductCtaBarWidget(
      detail: detail,
      inCart: inCart,
      onAddToCart: onAddToCart ?? () {},
      onViewCart: onViewCart ?? () {},
      onEdit: onEdit ?? () {},
      onOpenMenu: onOpenMenu ?? () {},
    ),
    wrapInScaffold: true,
  );
}

void main() {
  setUpAll(disableDsFonts);

  group('ProductCtaBarWidget', () {
    group('buyer (non-owner, active)', () {
      testWidgets('shows Add to cart button', (WidgetTester tester) async {
        await tester.pumpWidget(_wrap(detail: _detail()));
        await tester.pump();

        expect(find.text('Add to cart'), findsOneWidget);
      });

      testWidgets('onAddToCart fires when button is tapped', (
        WidgetTester tester,
      ) async {
        var called = false;
        await tester.pumpWidget(
          _wrap(detail: _detail(), onAddToCart: () => called = true),
        );
        await tester.pump();

        await tester.tap(find.text('Add to cart'));
        await tester.pump();

        expect(called, isTrue);
      });
    });

    group('buyer, already in cart', () {
      testWidgets('shows In cart · View cart text', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(_wrap(detail: _detail(), inCart: true));
        await tester.pump();

        expect(find.text('In cart · View cart'), findsOneWidget);
      });

      testWidgets('onViewCart fires when glass button is tapped', (
        WidgetTester tester,
      ) async {
        var called = false;
        await tester.pumpWidget(
          _wrap(
            detail: _detail(),
            inCart: true,
            onViewCart: () => called = true,
          ),
        );
        await tester.pump();

        await tester.tap(find.text('In cart · View cart'));
        await tester.pump();

        expect(called, isTrue);
      });
    });

    group('sold listing', () {
      testWidgets('shows Sold disabled label', (WidgetTester tester) async {
        await tester.pumpWidget(
          _wrap(detail: _detail(status: ProductStatus.sold)),
        );
        await tester.pump();

        expect(find.text('Sold'), findsOneWidget);
        expect(find.byType(DSButtonElevated), findsNothing);
      });
    });

    group('reserved listing', () {
      testWidgets('shows Reserved disabled label', (WidgetTester tester) async {
        await tester.pumpWidget(
          _wrap(detail: _detail(status: ProductStatus.reserved)),
        );
        await tester.pump();

        expect(find.text('Reserved'), findsOneWidget);
        expect(find.byType(DSButtonElevated), findsNothing);
      });
    });

    group('owner', () {
      testWidgets('shows Edit listing button and trash icon', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(_wrap(detail: _detail(isOwner: true)));
        await tester.pump();

        expect(find.text('Edit listing'), findsOneWidget);
        expect(find.byType(DSButtonElevated), findsOneWidget);
      });

      testWidgets('onEdit fires when Edit listing is tapped', (
        WidgetTester tester,
      ) async {
        var editCalled = false;
        await tester.pumpWidget(
          _wrap(
            detail: _detail(isOwner: true),
            onEdit: () => editCalled = true,
          ),
        );
        await tester.pump();

        await tester.tap(find.text('Edit listing'));
        await tester.pump();

        expect(editCalled, isTrue);
      });

      testWidgets('onOpenMenu fires when trash icon is tapped', (
        WidgetTester tester,
      ) async {
        var menuCalled = false;
        await tester.pumpWidget(
          _wrap(
            detail: _detail(isOwner: true),
            onOpenMenu: () => menuCalled = true,
          ),
        );
        await tester.pump();

        await tester.tap(find.byIcon(Icons.delete_outline_rounded));
        await tester.pump();

        expect(menuCalled, isTrue);
      });
    });
  });
}
