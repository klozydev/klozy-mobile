import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/domain/cart/entity/cart_item.dart';
import 'package:klozy/src/feature/cart/presentation/widget/offer_sheet.dart';

const _kItem1 = CartItem(productId: 'p1', title: 'Blue Jacket', price: 200);

const _kItem2 = CartItem(productId: 'p2', title: 'Red Shoes', price: 150);

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: dsTheme(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

OfferSheet _sheet({
  String sellerName = 'Test Seller',
  String? sellerAvatar,
  bool isPro = false,
  num subtotal = 200,
  List<CartItem> items = const <CartItem>[_kItem1],
}) {
  return OfferSheet(
    subtotal: subtotal,
    sellerName: sellerName,
    sellerAvatar: sellerAvatar,
    isPro: isPro,
    items: items,
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('OfferSheet', () {
    testWidgets('renders seller name', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(_sheet()));
      await tester.pump();
      expect(find.text('Test Seller'), findsOneWidget);
    });

    testWidgets('renders item titles', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(_sheet()));
      await tester.pump();
      expect(find.text('Blue Jacket'), findsOneWidget);
    });

    testWidgets('renders multiple item titles for multi-item sheet', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(_sheet(subtotal: 350, items: const <CartItem>[_kItem1, _kItem2])),
      );
      await tester.pump();
      expect(find.text('Blue Jacket'), findsOneWidget);
      expect(find.text('Red Shoes'), findsOneWidget);
    });

    testWidgets('renders PRO badge when isPro = true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(_sheet(isPro: true)));
      await tester.pump();
      expect(find.text('PRO'), findsOneWidget);
    });

    testWidgets('does not render PRO badge when isPro = false', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(_sheet(isPro: false)));
      await tester.pump();
      expect(find.text('PRO'), findsNothing);
    });

    testWidgets('send button is disabled when amount field is empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(_sheet()));
      await tester.pump();
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('send button becomes enabled for valid amount below subtotal', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(_sheet(subtotal: 200)));
      await tester.pump();
      // Enter a valid amount (e.g. 150 < 200)
      await tester.enterText(find.byType(TextField), '150');
      await tester.pump();
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('send button disabled when amount equals subtotal', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(_sheet(subtotal: 200)));
      await tester.pump();
      await tester.enterText(find.byType(TextField), '200');
      await tester.pump();
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('send button disabled when amount exceeds subtotal', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(_sheet(subtotal: 200)));
      await tester.pump();
      await tester.enterText(find.byType(TextField), '250');
      await tester.pump();
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('preset chip 70% fills field with rounded value', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(_sheet(subtotal: 200)));
      await tester.pump();
      // Tap the 70% chip
      await tester.tap(find.text('70%'));
      await tester.pump();
      // 200 * 0.7 = 140 — field should now show '140'
      expect(find.text('140'), findsOneWidget);
    });

    testWidgets('preset chip 80% fills field with rounded value', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(_sheet(subtotal: 200)));
      await tester.pump();
      await tester.tap(find.text('80%'));
      await tester.pump();
      // 200 * 0.8 = 160
      expect(find.text('160'), findsOneWidget);
    });

    testWidgets('preset chip 90% fills field with rounded value', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(_sheet(subtotal: 200)));
      await tester.pump();
      await tester.tap(find.text('90%'));
      await tester.pump();
      // 200 * 0.9 = 180
      expect(find.text('180'), findsOneWidget);
    });

    testWidgets('tapping preset enables send button for valid preset', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(_sheet(subtotal: 200)));
      await tester.pump();
      await tester.tap(find.text('80%'));
      await tester.pump();
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('renders placeholder icon when sellerAvatar is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(_sheet()));
      await tester.pump();
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('renders escrow note icon', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(_sheet()));
      await tester.pump();
      expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
    });
  });
}
