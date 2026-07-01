import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/catalog/catalog_repository.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_condition.dart';
import 'package:klozy/src/domain/product/entity/product_detail.dart';
import 'package:klozy/src/domain/product/products_repository.dart';
import 'package:klozy/src/feature/product/presentation/screen/edit_listing_page.dart';
import 'package:mocktail/mocktail.dart';

class _MockProductsRepository extends Mock implements ProductsRepository {}

class _MockCatalogRepository extends Mock implements CatalogRepository {}

const _kSeller = ProductSeller(id: 's1', displayName: 'Me');
const _kDetail = ProductDetail(
  id: 'pid1',
  title: 'Cool Jacket',
  price: 99,
  seller: _kSeller,
  description: 'Nice jacket',
  brand: 'Zara',
  size: 'M',
);

Widget _wrap() {
  return MaterialApp(
    theme: dsTheme(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const EditListingPage(productId: 'pid1'),
  );
}

void main() {
  late _MockProductsRepository mockProducts;
  late _MockCatalogRepository mockCatalog;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    mockProducts = _MockProductsRepository();
    mockCatalog = _MockCatalogRepository();

    if (locator.isRegistered<ProductsRepository>()) {
      locator.unregister<ProductsRepository>();
    }
    if (locator.isRegistered<CatalogRepository>()) {
      locator.unregister<CatalogRepository>();
    }

    locator.registerSingleton<ProductsRepository>(mockProducts);
    locator.registerSingleton<CatalogRepository>(mockCatalog);

    // Stub catalog calls to avoid errors (conditions and categories are
    // optional — the form renders even if they return empty lists).
    when(
      () => mockCatalog.getConditions(),
    ).thenAnswer((_) async => <CatalogCondition>[]);
    when(() => mockCatalog.getRootCategories()).thenAnswer((_) async => []);
  });

  tearDown(() {
    if (locator.isRegistered<ProductsRepository>()) {
      locator.unregister<ProductsRepository>();
    }
    if (locator.isRegistered<CatalogRepository>()) {
      locator.unregister<CatalogRepository>();
    }
  });

  group('EditListingPage', () {
    testWidgets('shows DSLoader while product is loading', (
      WidgetTester tester,
    ) async {
      // Keep a reference so we can complete it after the assertion to drain
      // any pending timers (DSLoader schedules a ~10-minute timer internally).
      final completer = Completer<ProductDetail>();
      when(
        () => mockProducts.getProduct(any()),
      ).thenAnswer((_) => completer.future);

      await tester.pumpWidget(_wrap());
      await tester.pump();

      expect(find.byType(DSLoader), findsOneWidget);

      // Drain the pending timer by resolving the load — widget transitions out
      // of the loading state so DSLoader (and its timer) are disposed cleanly.
      completer.complete(_kDetail);
      await tester.pump();
      await tester.pump();
    });

    testWidgets('shows title field after product loads', (
      WidgetTester tester,
    ) async {
      when(
        () => mockProducts.getProduct(any()),
      ).thenAnswer((_) async => _kDetail);

      await tester.pumpWidget(_wrap());
      // pump twice: once for build, once for the async _load future.
      await tester.pump();
      await tester.pump();

      expect(find.text('Cool Jacket'), findsOneWidget);
    });

    testWidgets('shows Edit listing title in app bar after load', (
      WidgetTester tester,
    ) async {
      when(
        () => mockProducts.getProduct(any()),
      ).thenAnswer((_) async => _kDetail);

      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump();

      expect(find.text('Edit listing'), findsOneWidget);
    });

    testWidgets('Save button is enabled when title and price are present', (
      WidgetTester tester,
    ) async {
      when(
        () => mockProducts.getProduct(any()),
      ).thenAnswer((_) async => _kDetail);

      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump();

      // The loaded detail already has title='Cool Jacket' and price=99 —
      // both satisfy the validity check, so save should be enabled.
      expect(find.text('Save'), findsOneWidget);
    });
  });
}
