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
import 'package:klozy/src/feature/sell/presentation/widget/sell_category_picker.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../support/ds_harness.dart';

class _MockCatalogRepository extends Mock implements CatalogRepository {}

const _kRoot = CatalogCategory(id: 'root1', label: 'Women', hasChildren: true);

void main() {
  late _MockCatalogRepository mockCatalog;

  setUpAll(disableDsFonts);

  setUp(() {
    mockCatalog = _MockCatalogRepository();
    // Default stubs.
    when(
      () => mockCatalog.getCategories(parentId: any(named: 'parentId')),
    ).thenAnswer((_) async => const <CatalogCategory>[]);
    when(
      () => mockCatalog.getRootCategories(),
    ).thenAnswer((_) async => const <CatalogCategory>[_kRoot]);
    when(
      () => mockCatalog.getConditions(),
    ).thenAnswer((_) async => const <CatalogCondition>[]);
    when(
      () => mockCatalog.searchBrands(query: any(named: 'query')),
    ).thenAnswer((_) async => const <CatalogBrand>[]);
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

  Widget buildWidget({CatalogCategory root = _kRoot}) {
    return dsWrap(Scaffold(body: SellCategoryPicker(root: root)));
  }

  testWidgets('shows DSLoader while children are loading', (tester) async {
    // Delay the response so the loading state is visible.
    // Never-completing future keeps the loading state visible without
    // scheduling a real timer that would still be pending at dispose.
    final completer = Completer<List<CatalogCategory>>();
    when(
      () => mockCatalog.getCategories(parentId: any(named: 'parentId')),
    ).thenAnswer((_) => completer.future);

    await tester.pumpWidget(buildWidget());
    // Before async completes.
    await tester.pump();

    expect(find.byType(DSLoader), findsOneWidget);
  });

  testWidgets('shows children after loading', (tester) async {
    const child1 = CatalogCategory(id: 'c1', label: 'Dresses');
    const child2 = CatalogCategory(id: 'c2', label: 'Tops');
    when(
      () => mockCatalog.getCategories(parentId: any(named: 'parentId')),
    ).thenAnswer((_) async => const <CatalogCategory>[child1, child2]);

    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    expect(find.text('Dresses'), findsOneWidget);
    expect(find.text('Tops'), findsOneWidget);
  });

  testWidgets('shows "use quoted" option when children list is empty', (
    tester,
  ) async {
    when(
      () => mockCatalog.getCategories(parentId: any(named: 'parentId')),
    ).thenAnswer((_) async => const <CatalogCategory>[]);

    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    // DSListItem with the "use quoted" text (contains root label).
    expect(find.byType(DSListItem), findsOneWidget);
  });

  testWidgets('tapping a leaf category pops with PickedCategory', (
    tester,
  ) async {
    const leaf = CatalogCategory(id: 'leaf1', label: 'T-Shirts');
    when(
      () => mockCatalog.getCategories(parentId: any(named: 'parentId')),
    ).thenAnswer((_) async => const <CatalogCategory>[leaf]);

    PickedCategory? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () async {
                result = await Navigator.of(ctx).push<PickedCategory>(
                  MaterialPageRoute(
                    builder: (_) =>
                        const Scaffold(body: SellCategoryPicker(root: _kRoot)),
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

    // Leaf item visible.
    expect(find.text('T-Shirts'), findsOneWidget);

    await tester.tap(find.text('T-Shirts'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.id, 'leaf1');
  });

  testWidgets('tapping a non-leaf loads its children', (tester) async {
    const parent = CatalogCategory(id: 'p1', label: 'Shoes', hasChildren: true);
    const childOfParent = CatalogCategory(id: 'c1', label: 'Sneakers');

    when(
      () => mockCatalog.getCategories(parentId: 'root1'),
    ).thenAnswer((_) async => const <CatalogCategory>[parent]);
    when(
      () => mockCatalog.getCategories(parentId: 'p1'),
    ).thenAnswer((_) async => const <CatalogCategory>[childOfParent]);

    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Shoes'));
    await tester.pumpAndSettle();

    expect(find.text('Sneakers'), findsOneWidget);
  });
}
