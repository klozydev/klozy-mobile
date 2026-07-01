import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/design/components/ds_category_tree_picker.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/catalog/catalog_repository.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_brand.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_category.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_condition.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_size_value.dart';
import 'package:klozy/src/feature/sell/presentation/screen/sell_category_page.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../support/ds_harness.dart';

class _MockCatalogRepository extends Mock implements CatalogRepository {}

class _MockStackRouter extends Mock implements StackRouter {}

// ignore: avoid_implementing_value_types
class _FakeRoute extends Fake implements PageRouteInfo<Object?> {}

void main() {
  late _MockCatalogRepository mockCatalog;
  late _MockStackRouter router;

  setUpAll(() {
    disableDsFonts();
    registerFallbackValue(_FakeRoute());
  });

  setUp(() {
    mockCatalog = _MockCatalogRepository();
    when(
      () => mockCatalog.getCategories(parentId: any(named: 'parentId')),
    ).thenAnswer((_) async => const <CatalogCategory>[]);
    when(
      () => mockCatalog.getRootCategories(),
    ).thenAnswer((_) async => const <CatalogCategory>[]);
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

    router = _MockStackRouter();
    when(() => router.maybePop<Object?>()).thenAnswer((_) async => true);
    when(
      () => router.maybePop<PickedCategory>(any()),
    ).thenAnswer((_) async => true);
  });

  tearDown(() {
    if (locator.isRegistered<CatalogRepository>()) {
      locator.unregister<CatalogRepository>();
    }
  });

  Widget buildPage({CatalogCategory? parent}) {
    return dsWrapRouted(SellCategoryPage(parent: parent), router: router);
  }

  testWidgets('renders DSCategoryTreePicker', (tester) async {
    await tester.pumpWidget(buildPage());
    await tester.pump();

    expect(find.byType(DSCategoryTreePicker), findsOneWidget);
  });

  testWidgets('renders AppBar with back button (push type)', (tester) async {
    await tester.pumpWidget(buildPage());
    await tester.pump();

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_ios), findsOneWidget);
  });

  testWidgets('renders without a parent (null parent)', (tester) async {
    await tester.pumpWidget(buildPage());
    await tester.pump();

    expect(find.byType(Scaffold), findsOneWidget);
  });

  testWidgets('renders with a non-null parent category', (tester) async {
    const parent = CatalogCategory(
      id: 'women',
      label: 'Women',
      hasChildren: true,
    );
    when(() => mockCatalog.getCategories(parentId: 'women')).thenAnswer(
      (_) async => const <CatalogCategory>[
        CatalogCategory(id: 'dresses', label: 'Dresses'),
      ],
    );

    await tester.pumpWidget(buildPage(parent: parent));
    await tester.pumpAndSettle();

    // DSCategoryTreePicker should be present and eventually show children.
    expect(find.byType(DSCategoryTreePicker), findsOneWidget);
  });

  testWidgets('wrappedRoute returns the page itself', (tester) async {
    const page = SellCategoryPage();
    await tester.pumpWidget(
      dsWrapRouted(
        Builder(builder: (ctx) => page.wrappedRoute(ctx)),
        router: router,
      ),
    );
    await tester.pump();

    expect(find.byType(SellCategoryPage), findsOneWidget);
  });

  testWidgets('leaf selection calls router.maybePop with PickedCategory', (
    tester,
  ) async {
    const leaf = CatalogCategory(id: 'dresses', label: 'Dresses');
    when(
      () => mockCatalog.getCategories(parentId: any(named: 'parentId')),
    ).thenAnswer((_) async => const <CatalogCategory>[leaf]);

    await tester.pumpWidget(buildPage());
    await tester.pumpAndSettle();

    // Tap the leaf item.
    await tester.tap(find.text('Dresses'));
    await tester.pumpAndSettle();

    verify(() => router.maybePop<PickedCategory>(any())).called(1);
  });
}
