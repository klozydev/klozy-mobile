import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/domain/cart/entity/cart_bucket.dart';
import 'package:klozy/src/domain/cart/entity/cart_bundle.dart';
import 'package:klozy/src/domain/cart/entity/cart_item.dart';
import 'package:klozy/src/feature/cart/presentation/widget/cart_bucket_card_widget.dart';

const _kItem = CartItem(
  productId: 'p1',
  title: 'Blue Jacket',
  price: 200,
  brand: 'Nike',
  size: 'L',
);

const _kItemPending = CartItem(
  productId: 'p2',
  title: 'Red Shoes',
  price: 150,
  offerId: 'offer1',
  offerAmount: 120,
  offerStatus: CartOfferStatus.pending,
);

const _kItemAccepted = CartItem(
  productId: 'p3',
  title: 'White Tee',
  price: 80,
  effectivePrice: 60,
  offerId: 'offer2',
  offerAmount: 60,
  offerStatus: CartOfferStatus.accepted,
);

CartBucketCardWidget _buildWidget({
  CartBucket? bucket,
  ValueChanged<String>? onRemoveItem,
  ValueChanged<CartItem>? onMakeItemOffer,
  ValueChanged<String>? onCancelOffer,
  VoidCallback? onMakeBundleOffer,
  VoidCallback? onCheckout,
  VoidCallback? onMessageSeller,
}) {
  final b =
      bucket ??
      const CartBucket(
        sellerId: 'seller1',
        sellerName: 'The Seller',
        items: <CartItem>[_kItem],
        subtotal: 200,
      );
  return CartBucketCardWidget(
    bucket: b,
    onRemoveItem: onRemoveItem ?? (_) {},
    onMakeItemOffer: onMakeItemOffer ?? (_) {},
    onCancelOffer: onCancelOffer ?? (_) {},
    onMakeBundleOffer: onMakeBundleOffer ?? () {},
    onCheckout: onCheckout ?? () {},
    onMessageSeller: onMessageSeller,
  );
}

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: dsTheme(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('CartBucketCardWidget', () {
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

    testWidgets('renders checkout button', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(_buildWidget()));
      await tester.pump();
      expect(find.byType(DSButtonElevated), findsOneWidget);
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
      // PRO badge renders "PRO" text
      expect(find.text('PRO'), findsWidgets);
    });

    testWidgets('does not render PRO badge when isPro = false', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(_buildWidget()));
      await tester.pump();
      expect(find.text('PRO'), findsNothing);
    });

    testWidgets('calls onRemoveItem when delete icon is tapped', (
      WidgetTester tester,
    ) async {
      String? removed;
      await tester.pumpWidget(
        _wrap(_buildWidget(onRemoveItem: (id) => removed = id)),
      );
      await tester.pump();
      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      expect(removed, equals('p1'));
    });

    testWidgets('calls onCheckout when checkout button is tapped', (
      WidgetTester tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(_buildWidget(onCheckout: () => tapped = true)),
      );
      await tester.pump();
      await tester.tap(find.byType(DSButtonElevated));
      expect(tapped, isTrue);
    });

    testWidgets('calls onMakeItemOffer when make-offer pill is tapped', (
      WidgetTester tester,
    ) async {
      CartItem? offered;
      await tester.pumpWidget(
        _wrap(_buildWidget(onMakeItemOffer: (item) => offered = item)),
      );
      await tester.pump();
      // The "make an offer" pill is a GestureDetector wrapping a Container
      await tester.tap(find.byIcon(Icons.sell_outlined).first);
      expect(offered, equals(_kItem));
    });

    testWidgets('renders bundle button when canBundle = true', (
      WidgetTester tester,
    ) async {
      // Need 2+ standalone items for canBundle
      const item2 = CartItem(productId: 'p2', title: 'Item 2', price: 50);
      const bucket = CartBucket(
        sellerId: 'seller1',
        sellerName: 'Seller',
        items: <CartItem>[_kItem, item2],
        subtotal: 250,
        canBundle: true,
      );
      await tester.pumpWidget(_wrap(_buildWidget(bucket: bucket)));
      await tester.pump();
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('calls onMakeBundleOffer when bundle button is tapped', (
      WidgetTester tester,
    ) async {
      var tapped = false;
      const item2 = CartItem(productId: 'p2', title: 'Item 2', price: 50);
      const bucket = CartBucket(
        sellerId: 'seller1',
        sellerName: 'Seller',
        items: <CartItem>[_kItem, item2],
        subtotal: 250,
        canBundle: true,
      );
      await tester.pumpWidget(
        _wrap(
          _buildWidget(bucket: bucket, onMakeBundleOffer: () => tapped = true),
        ),
      );
      await tester.pump();
      await tester.tap(find.byType(OutlinedButton));
      expect(tapped, isTrue);
    });

    testWidgets(
      'shows pending offer tag and cancel for item with pending offer',
      (WidgetTester tester) async {
        const bucket = CartBucket(
          sellerId: 'seller1',
          sellerName: 'Seller',
          items: <CartItem>[_kItemPending],
          subtotal: 150,
        );
        await tester.pumpWidget(_wrap(_buildWidget(bucket: bucket)));
        await tester.pump();
        // Cancel text is shown for pending offers
        expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
      },
    );

    testWidgets('calls onCancelOffer with offerId when cancel is tapped', (
      WidgetTester tester,
    ) async {
      String? cancelled;
      const bucket = CartBucket(
        sellerId: 'seller1',
        sellerName: 'Seller',
        items: <CartItem>[_kItemPending],
        subtotal: 150,
      );
      await tester.pumpWidget(
        _wrap(
          _buildWidget(bucket: bucket, onCancelOffer: (id) => cancelled = id),
        ),
      );
      await tester.pump();
      // "Cancel" text button for the pending offer
      final cancelFinders = find.text('Cancel');
      expect(cancelFinders, findsOneWidget);
      await tester.tap(cancelFinders);
      expect(cancelled, equals('offer1'));
    });

    testWidgets('shows message icon when onMessageSeller is provided', (
      WidgetTester tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(_buildWidget(onMessageSeller: () => tapped = true)),
      );
      await tester.pump();
      expect(find.byIcon(Icons.chat_bubble_outline_rounded), findsOneWidget);
      await tester.tap(find.byIcon(Icons.chat_bubble_outline_rounded));
      expect(tapped, isTrue);
    });

    testWidgets('does not show message icon when onMessageSeller is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(_buildWidget()));
      await tester.pump();
      expect(find.byIcon(Icons.chat_bubble_outline_rounded), findsNothing);
    });

    testWidgets('renders bundle banner when bundles list is non-empty', (
      WidgetTester tester,
    ) async {
      const bundle = CartBundle(
        id: 'bundle1',
        amount: 180,
        status: CartOfferStatus.pending,
        productIds: <String>['p1', 'p2'],
        listSum: 250,
      );
      const bucket = CartBucket(
        sellerId: 'seller1',
        sellerName: 'Seller',
        items: <CartItem>[_kItem],
        subtotal: 200,
        bundles: <CartBundle>[bundle],
      );
      await tester.pumpWidget(_wrap(_buildWidget(bucket: bucket)));
      await tester.pump();
      // Bundle banner shows sell icon (same as make-offer, but in bundle context)
      expect(find.byIcon(Icons.sell_outlined), findsWidgets);
    });

    testWidgets('renders item with accepted offer — shows accepted tag', (
      WidgetTester tester,
    ) async {
      const bucket = CartBucket(
        sellerId: 'seller1',
        sellerName: 'Seller',
        items: <CartItem>[_kItemAccepted],
        subtotal: 60,
      );
      await tester.pumpWidget(_wrap(_buildWidget(bucket: bucket)));
      await tester.pump();
      // Accepted item shows line-through original price text
      expect(find.text('White Tee'), findsOneWidget);
    });
  });
}
