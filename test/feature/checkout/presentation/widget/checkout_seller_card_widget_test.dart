import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/domain/cart/entity/cart_bucket.dart';
import 'package:klozy/src/domain/cart/entity/cart_item.dart';
import 'package:klozy/src/feature/checkout/presentation/widget/checkout_seller_card_widget.dart';

const _kItem = CartItem(
  productId: 'p1',
  title: 'Blue Jacket',
  price: 200,
  brand: 'Nike',
  size: 'L',
);

const _kItem2 = CartItem(productId: 'p2', title: 'Red Shoes', price: 150);

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: dsTheme(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

CheckoutSellerCardWidget _buildWidget({
  CartBucket? bucket,
  VoidCallback? onOpenSeller,
  VoidCallback? onMessage,
}) {
  final b =
      bucket ??
      const CartBucket(
        sellerId: 'seller1',
        sellerName: 'The Seller',
        items: <CartItem>[_kItem],
        subtotal: 200,
      );
  return CheckoutSellerCardWidget(
    bucket: b,
    onOpenSeller: onOpenSeller ?? () {},
    onMessage: onMessage ?? () {},
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('CheckoutSellerCardWidget', () {
    testWidgets('renders seller name', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(_buildWidget()));
      await tester.pump();
      expect(find.text('The Seller'), findsOneWidget);
    });

    testWidgets('renders item title', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(_buildWidget()));
      await tester.pump();
      expect(find.text('Blue Jacket'), findsOneWidget);
    });

    testWidgets('renders all item titles for multiple items', (
      WidgetTester tester,
    ) async {
      const bucket = CartBucket(
        sellerId: 'seller1',
        sellerName: 'The Seller',
        items: <CartItem>[_kItem, _kItem2],
        subtotal: 350,
      );
      await tester.pumpWidget(_wrap(_buildWidget(bucket: bucket)));
      await tester.pump();
      expect(find.text('Blue Jacket'), findsOneWidget);
      expect(find.text('Red Shoes'), findsOneWidget);
    });

    testWidgets('renders PRO badge when isPro = true', (
      WidgetTester tester,
    ) async {
      const bucket = CartBucket(
        sellerId: 'seller1',
        sellerName: 'Pro Seller',
        items: <CartItem>[_kItem],
        subtotal: 200,
        isPro: true,
      );
      await tester.pumpWidget(_wrap(_buildWidget(bucket: bucket)));
      await tester.pump();
      expect(find.text('PRO'), findsOneWidget);
    });

    testWidgets('does not render PRO badge when isPro = false', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(_buildWidget()));
      await tester.pump();
      expect(find.text('PRO'), findsNothing);
    });

    testWidgets('calls onOpenSeller when seller area is tapped', (
      WidgetTester tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(_buildWidget(onOpenSeller: () => tapped = true)),
      );
      await tester.pump();
      // Seller area is a GestureDetector wrapping the avatar + name row
      await tester.tap(find.text('The Seller'));
      expect(tapped, isTrue);
    });

    testWidgets('calls onMessage when chat button is tapped', (
      WidgetTester tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(_buildWidget(onMessage: () => tapped = true)),
      );
      await tester.pump();
      await tester.tap(find.byIcon(Icons.chat_bubble_outline_rounded));
      expect(tapped, isTrue);
    });

    testWidgets('renders placeholder icon when sellerAvatar is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(_buildWidget()));
      await tester.pump();
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('renders item meta (brand · size) when non-empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(_buildWidget()));
      await tester.pump();
      // meta = 'Nike · L'
      expect(find.text('Nike · L'), findsOneWidget);
    });

    testWidgets('renders item placeholder when image is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(_buildWidget()));
      await tester.pump();
      // ColoredBox used as placeholder when image is null
      expect(find.byType(ColoredBox), findsWidgets);
    });
  });
}
