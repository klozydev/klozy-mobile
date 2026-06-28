import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/design/components/ds_list_item.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/catalog/catalog_repository.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_brand.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_category.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_condition.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_size_value.dart';
import 'package:klozy/src/feature/sell/presentation/widget/sell_brand_picker.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../support/ds_harness.dart';

class _MockCatalogRepository extends Mock implements CatalogRepository {}

void main() {
  late _MockCatalogRepository mockCatalog;

  setUpAll(disableDsFonts);

  setUp(() {
    mockCatalog = _MockCatalogRepository();
    when(
      () => mockCatalog.searchBrands(query: any(named: 'query')),
    ).thenAnswer((_) async => const <CatalogBrand>[]);
    when(
      () => mockCatalog.getRootCategories(),
    ).thenAnswer((_) async => const <CatalogCategory>[]);
    when(
      () => mockCatalog.getCategories(parentId: any(named: 'parentId')),
    ).thenAnswer((_) async => const <CatalogCategory>[]);
    when(
      () => mockCatalog.getConditions(),
    ).thenAnswer((_) async => const <CatalogCondition>[]);
    when(
      () => mockCatalog.getSizes(),
    ).thenAnswer((_) async => const <CatalogSizeValue>[]);
    when(
      () => mockCatalog.getSizeConfig(any()),
    ).thenAnswer((_) async => const <CatalogSizeValue>[]);

    if (!locator.isRegistered<CatalogRepository>()) {
      locator.registerSingleton<CatalogRepository>(mockCatalog);
    }
  });

  tearDown(() {
    if (locator.isRegistered<CatalogRepository>()) {
      locator.unregister<CatalogRepository>();
    }
  });

  Widget buildWidget() {
    return dsWrap(const Scaffold(body: SellBrandPicker()));
  }

  testWidgets('shows DSLoader while brands are loading', (tester) async {
    // Never-completing future keeps the loading state visible without
    // scheduling a real timer that would still be pending at dispose.
    final completer = Completer<List<CatalogBrand>>();
    when(
      () => mockCatalog.searchBrands(query: any(named: 'query')),
    ).thenAnswer((_) => completer.future);

    await tester.pumpWidget(buildWidget());
    await tester.pump();

    expect(find.byType(DSLoader), findsOneWidget);
  });

  testWidgets('shows brand list after loading', (tester) async {
    const brands = [
      CatalogBrand(id: 'b1', name: 'Nike'),
      CatalogBrand(id: 'b2', name: 'Adidas'),
    ];
    when(
      () => mockCatalog.searchBrands(query: any(named: 'query')),
    ).thenAnswer((_) async => brands);

    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    expect(find.text('Nike'), findsOneWidget);
    expect(find.text('Adidas'), findsOneWidget);
    expect(find.byType(DSListItem), findsNWidgets(2));
  });

  testWidgets('shows empty list when no brands returned', (tester) async {
    when(
      () => mockCatalog.searchBrands(query: any(named: 'query')),
    ).thenAnswer((_) async => const <CatalogBrand>[]);

    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    expect(find.byType(DSListItem), findsNothing);
    expect(find.byType(DSLoader), findsNothing);
  });

  testWidgets('tapping a brand pops with PickedBrand', (tester) async {
    const brands = [CatalogBrand(id: 'b1', name: 'Nike')];
    when(
      () => mockCatalog.searchBrands(query: any(named: 'query')),
    ).thenAnswer((_) async => brands);

    PickedBrand? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () async {
                result = await Navigator.of(ctx).push<PickedBrand>(
                  MaterialPageRoute(
                    builder: (_) => const Scaffold(body: SellBrandPicker()),
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
        localizationsDelegates: const [],
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Nike'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.id, 'b1');
    expect(result!.name, 'Nike');
  });
}
