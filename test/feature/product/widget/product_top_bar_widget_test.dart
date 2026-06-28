import 'package:auto_route/auto_route.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/app/wishlist/wishlist_cubit.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/domain/product/entity/product_detail.dart';
import 'package:klozy/src/domain/wishlist/wishlist_repository.dart';
import 'package:klozy/src/feature/product/presentation/widget/product_heart_button_widget.dart';
import 'package:klozy/src/feature/product/presentation/widget/product_top_bar_widget.dart';
import 'package:klozy/src/router/app_router.dart';
import 'package:mocktail/mocktail.dart';

class _MockStackRouter extends Mock implements StackRouter {}

class _MockWishlistRepository extends Mock implements WishlistRepository {}

Widget _wrap(
  ProductDetail detail, {
  required StackRouter router,
  WishlistCubit? wishlist,
}) {
  Widget child = StackRouterScope(
    controller: router,
    stateHash: 0,
    child: Scaffold(body: ProductTopBarWidget(detail: detail)),
  );
  if (wishlist != null) {
    child = BlocProvider<WishlistCubit>.value(value: wishlist, child: child);
  }
  return MaterialApp(
    theme: dsTheme(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );
}

const _kSeller = ProductSeller(id: 's1', displayName: 'Alice');

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    registerFallbackValue(const WelcomeRoute());
  });

  group('ProductTopBarWidget', () {
    late _MockStackRouter router;

    setUp(() {
      router = _MockStackRouter();
      when(() => router.maybePop<Object?>()).thenAnswer((_) async => true);
    });

    testWidgets('shows back button', (WidgetTester tester) async {
      const detail = ProductDetail(
        id: 'p1',
        title: 'Item',
        price: 50,
        seller: _kSeller,
        isOwner: true,
      );
      await tester.pumpWidget(_wrap(detail, router: router));
      await tester.pump();

      expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
    });

    testWidgets('shows heart button for non-owner', (
      WidgetTester tester,
    ) async {
      const detail = ProductDetail(
        id: 'p1',
        title: 'Item',
        price: 50,
        seller: _kSeller,
        isOwner: false,
      );
      final wishlist = WishlistCubit(_MockWishlistRepository(), EventBus());
      await tester.pumpWidget(
        _wrap(detail, router: router, wishlist: wishlist),
      );
      await tester.pump();

      expect(find.byType(ProductHeartButtonWidget), findsOneWidget);
    });

    testWidgets('hides heart button for owner', (WidgetTester tester) async {
      const detail = ProductDetail(
        id: 'p1',
        title: 'Item',
        price: 50,
        seller: _kSeller,
        isOwner: true,
      );
      await tester.pumpWidget(_wrap(detail, router: router));
      await tester.pump();

      expect(find.byType(ProductHeartButtonWidget), findsNothing);
    });

    testWidgets('shows share button', (WidgetTester tester) async {
      const detail = ProductDetail(
        id: 'p1',
        title: 'Item',
        price: 50,
        seller: _kSeller,
        isOwner: true,
      );
      await tester.pumpWidget(_wrap(detail, router: router));
      await tester.pump();

      expect(find.byIcon(Icons.ios_share_rounded), findsOneWidget);
    });
  });
}
