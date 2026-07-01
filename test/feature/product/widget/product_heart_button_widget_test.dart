import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/app/wishlist/wishlist_cubit.dart';
import 'package:klozy/src/core/account/account_gate.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/domain/product/entity/product_detail.dart';
import 'package:klozy/src/domain/wishlist/wishlist_repository.dart';
import 'package:klozy/src/feature/product/presentation/widget/product_heart_button_widget.dart';
import 'package:mocktail/mocktail.dart';

class _MockWishlistRepository extends Mock implements WishlistRepository {}

const _kSeller = ProductSeller(id: 's1', displayName: 'Seller');
const _kDetail = ProductDetail(
  id: 'p1',
  title: 'Hat',
  price: 50,
  seller: _kSeller,
);

Widget _wrap(WishlistCubit cubit) {
  return BlocProvider<WishlistCubit>.value(
    value: cubit,
    child: MaterialApp(
      theme: dsTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: ProductHeartButtonWidget(detail: _kDetail)),
    ),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  tearDown(() async {
    if (GetIt.instance.isRegistered<AccountGate>()) {
      await GetIt.instance.reset();
    }
  });

  group('ProductHeartButtonWidget', () {
    testWidgets('shows unfilled heart when product is not in wishlist', (
      WidgetTester tester,
    ) async {
      final cubit = WishlistCubit(_MockWishlistRepository(), EventBus());
      await tester.pumpWidget(_wrap(cubit));
      await tester.pump();

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsNothing);
    });

    testWidgets('shows filled heart when product is in wishlist', (
      WidgetTester tester,
    ) async {
      final cubit = WishlistCubit(_MockWishlistRepository(), EventBus());
      cubit.emit(<String>{_kDetail.id});

      await tester.pumpWidget(_wrap(cubit));
      await tester.pump();

      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);
    });
  });
}
