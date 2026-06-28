import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/app/wishlist/wishlist_cubit.dart';
import 'package:klozy/src/design/components/ds_category_tree_picker.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/catalog/catalog_repository.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_brand.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_category.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_condition.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_size_value.dart';
import 'package:klozy/src/domain/product/entity/feed_page.dart';
import 'package:klozy/src/domain/product/entity/product.dart';
import 'package:klozy/src/domain/product/products_repository.dart';
import 'package:klozy/src/feature/search/presentation/screen/search_category_page.dart';
import 'package:klozy/src/feature/search/presentation/widget/category_products_widget.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../support/ds_harness.dart';

class _MockCatalogRepository extends Mock implements CatalogRepository {}

class _MockProductsRepository extends Mock implements ProductsRepository {}

class _MockWishlistCubit extends Mock implements WishlistCubit {}

class _MockStackRouter extends Mock implements StackRouter {}

const _kRoot = CatalogCategory(id: 'women', label: 'Women', hasChildren: true);

void main() {
  setUpAll(disableDsFonts);

  late _MockCatalogRepository mockCatalog;
  late _MockProductsRepository mockProducts;
  late _MockWishlistCubit mockWishlist;
  late _MockStackRouter mockRouter;

  setUp(() {
    mockCatalog = _MockCatalogRepository();
    mockProducts = _MockProductsRepository();
    mockWishlist = _MockWishlistCubit();
    mockRouter = _MockStackRouter();

    when(() => mockWishlist.state).thenReturn(const <String>{});
    when(() => mockWishlist.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockRouter.maybePop<Object?>()).thenAnswer((_) async => true);
    when(() => mockRouter.canPop()).thenReturn(true);

    when(
      () => mockCatalog.getCategories(parentId: any(named: 'parentId')),
    ).thenAnswer((_) async => <CatalogCategory>[]);

    when(
      () => mockCatalog.getRootCategories(),
    ).thenAnswer((_) async => <CatalogCategory>[]);

    when(
      () => mockCatalog.getConditions(),
    ).thenAnswer((_) async => <CatalogCondition>[]);

    when(
      () => mockCatalog.getSizeConfig(any()),
    ).thenAnswer((_) async => <CatalogSizeValue>[]);

    when(
      () => mockCatalog.searchBrands(query: any(named: 'query')),
    ).thenAnswer((_) async => <CatalogBrand>[]);

    when(
      () => mockCatalog.getSizes(),
    ).thenAnswer((_) async => <CatalogSizeValue>[]);

    when(
      () => mockProducts.feed(
        categoryId: any(named: 'categoryId'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const FeedPage(data: <Product>[]));

    if (locator.isRegistered<CatalogRepository>()) {
      locator.unregister<CatalogRepository>();
    }
    locator.registerSingleton<CatalogRepository>(mockCatalog);

    if (locator.isRegistered<ProductsRepository>()) {
      locator.unregister<ProductsRepository>();
    }
    locator.registerSingleton<ProductsRepository>(mockProducts);
  });

  tearDown(() {
    if (locator.isRegistered<CatalogRepository>()) {
      locator.unregister<CatalogRepository>();
    }
    if (locator.isRegistered<ProductsRepository>()) {
      locator.unregister<ProductsRepository>();
    }
  });

  Widget build() {
    return dsWrapRouted(
      BlocProvider<WishlistCubit>.value(
        value: mockWishlist,
        child: const SearchCategoryPage(root: _kRoot),
      ),
      router: mockRouter,
    );
  }

  group('SearchCategoryPage — initial state', () {
    testWidgets('renders with root label in app bar', (tester) async {
      await tester.pumpWidget(build());
      await tester.pumpAndSettle();

      // "Women" also appears in the tree picker breadcrumb — scope to the bar.
      expect(
        find.descendant(of: find.byType(AppBar), matching: find.text('Women')),
        findsOneWidget,
      );
    });

    testWidgets('shows DSCategoryTreePicker when no leaf is selected', (
      tester,
    ) async {
      await tester.pumpWidget(build());
      await tester.pumpAndSettle();

      expect(find.byType(DSCategoryTreePicker), findsOneWidget);
    });

    testWidgets('does not show CategoryProductsWidget initially', (
      tester,
    ) async {
      await tester.pumpWidget(build());
      await tester.pumpAndSettle();

      expect(find.byType(CategoryProductsWidget), findsNothing);
    });
  });

  group('SearchCategoryPage — leaf selection', () {
    testWidgets(
      'shows CategoryProductsWidget and breadcrumb after onLeafSelected fires',
      (tester) async {
        await tester.pumpWidget(build());
        await tester.pumpAndSettle();

        // Simulate leaf selection through the public DSCategoryTreePicker callback.
        final picker = tester.widget<DSCategoryTreePicker>(
          find.byType(DSCategoryTreePicker),
        );
        picker.onLeafSelected(
          const PickedCategory(id: 'dresses', path: 'Women › Dresses'),
        );
        await tester.pumpAndSettle();

        expect(find.byType(CategoryProductsWidget), findsOneWidget);
        expect(find.text('Women › Dresses'), findsOneWidget);
      },
    );

    testWidgets('hides DSCategoryTreePicker after leaf is selected', (
      tester,
    ) async {
      await tester.pumpWidget(build());
      await tester.pumpAndSettle();

      final picker = tester.widget<DSCategoryTreePicker>(
        find.byType(DSCategoryTreePicker),
      );
      picker.onLeafSelected(
        const PickedCategory(id: 'dresses', path: 'Women › Dresses'),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DSCategoryTreePicker), findsNothing);
    });
  });

  group('SearchCategoryPage — back navigation', () {
    testWidgets('back button pops the route when no leaf is selected', (
      tester,
    ) async {
      // The page pops via Navigator.of(context).maybePop(); push it onto a
      // real route stack so the pop is observable.
      await tester.pumpWidget(
        dsWrap(
          Builder(
            builder: (BuildContext context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => BlocProvider<WishlistCubit>.value(
                        value: mockWishlist,
                        child: const SearchCategoryPage(root: _kRoot),
                      ),
                    ),
                  ),
                  child: const Text('go'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      expect(find.byType(SearchCategoryPage), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_ios));
      await tester.pumpAndSettle();

      expect(find.byType(SearchCategoryPage), findsNothing);
    });

    testWidgets(
      'back button clears leaf and shows tree again without popping',
      (tester) async {
        await tester.pumpWidget(build());
        await tester.pumpAndSettle();

        // Select a leaf.
        final picker = tester.widget<DSCategoryTreePicker>(
          find.byType(DSCategoryTreePicker),
        );
        picker.onLeafSelected(
          const PickedCategory(id: 'dresses', path: 'Women › Dresses'),
        );
        await tester.pumpAndSettle();
        expect(find.byType(CategoryProductsWidget), findsOneWidget);

        // Press back — should clear the leaf, not pop the route.
        await tester.tap(find.byIcon(Icons.arrow_back_ios));
        await tester.pump();

        expect(find.byType(DSCategoryTreePicker), findsOneWidget);
        expect(find.byType(CategoryProductsWidget), findsNothing);
        verifyNever(() => mockRouter.maybePop<Object?>());
      },
    );

    testWidgets('app bar title reverts to root label after leaf is cleared', (
      tester,
    ) async {
      await tester.pumpWidget(build());
      await tester.pumpAndSettle();

      final picker = tester.widget<DSCategoryTreePicker>(
        find.byType(DSCategoryTreePicker),
      );
      picker.onLeafSelected(
        const PickedCategory(id: 'dresses', path: 'Women › Dresses'),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back_ios));
      await tester.pump();

      // Root label is back in the title (also present in the breadcrumb).
      expect(
        find.descendant(of: find.byType(AppBar), matching: find.text('Women')),
        findsOneWidget,
      );
    });
  });
}
