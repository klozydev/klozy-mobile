import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/app/wishlist/wishlist_cubit.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/domain/product/entity/product.dart';
import 'package:klozy/src/domain/wishlist/wishlist_repository.dart';
import 'package:klozy/src/feature/home/presentation/widget/product_card_widget.dart';
import 'package:mocktail/mocktail.dart';

class _MockWishlistRepository extends Mock implements WishlistRepository {}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('ProductCardWidget — currency display', () {
    Widget buildCard(Product product) {
      final wishlist = WishlistCubit(_MockWishlistRepository(), EventBus());
      return BlocProvider<WishlistCubit>.value(
        value: wishlist,
        child: MaterialApp(
          theme: dsTheme(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: ProductCardWidget(product: product)),
        ),
      );
    }

    testWidgets('shows price amount followed by Dhs currency', (
      WidgetTester tester,
    ) async {
      const product = Product(
        id: 'p1',
        title: 'Cool Sneakers',
        price: 250,
        brand: 'Nike',
        size: '42',
      );

      await tester.pumpWidget(buildCard(product));
      await tester.pump();

      // The rendered price text must contain the amount and the currency.
      expect(find.textContaining('250'), findsWidgets);
      expect(find.textContaining('Dhs'), findsOneWidget);
    });

    testWidgets('price text is formatted as "<amount> Dhs"', (
      WidgetTester tester,
    ) async {
      const product = Product(id: 'p2', title: 'Leather Jacket', price: 1200);

      await tester.pumpWidget(buildCard(product));
      await tester.pump();

      expect(find.text('1200 Dhs'), findsOneWidget);
    });

    testWidgets('decimal price is truncated to int before Dhs', (
      WidgetTester tester,
    ) async {
      const product = Product(id: 'p3', title: 'Cap', price: 89.99);

      await tester.pumpWidget(buildCard(product));
      await tester.pump();

      // price.toInt() = 89 → "89 Dhs"
      expect(find.text('89 Dhs'), findsOneWidget);
    });
  });
}
