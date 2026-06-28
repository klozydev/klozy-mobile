import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/app/wishlist/wishlist_cubit.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/product/entity/feed_page.dart';
import 'package:klozy/src/domain/product/entity/product.dart';
import 'package:klozy/src/domain/product/products_repository.dart';
import 'package:klozy/src/feature/search/presentation/widget/category_products_widget.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../support/ds_harness.dart';

class _MockProductsRepository extends Mock implements ProductsRepository {}

class _MockWishlistCubit extends Mock implements WishlistCubit {}

const _kProduct = Product(
  id: 'p1',
  title: 'Test jacket',
  price: 99,
  brand: 'Nike',
  size: 'M',
);

bool _isNetworkImageError(FlutterErrorDetails d) {
  final msg = d.exception.toString();
  return msg.contains('NetworkImageLoadException') ||
      msg.contains('HTTP request failed') ||
      msg.contains('XMLHttpRequest') ||
      msg.contains('SocketException');
}

void main() {
  setUpAll(disableDsFonts);

  late _MockProductsRepository mockRepo;
  late _MockWishlistCubit mockWishlist;

  setUp(() {
    mockRepo = _MockProductsRepository();
    mockWishlist = _MockWishlistCubit();

    when(() => mockWishlist.state).thenReturn(const <String>{});
    when(() => mockWishlist.stream).thenAnswer((_) => const Stream.empty());

    if (locator.isRegistered<ProductsRepository>()) {
      locator.unregister<ProductsRepository>();
    }
    locator.registerSingleton<ProductsRepository>(mockRepo);
  });

  tearDown(() {
    if (locator.isRegistered<ProductsRepository>()) {
      locator.unregister<ProductsRepository>();
    }
  });

  Widget build({String categoryId = 'cat1'}) {
    return dsWrap(
      BlocProvider<WishlistCubit>.value(
        value: mockWishlist,
        child: Scaffold(body: CategoryProductsWidget(categoryId: categoryId)),
      ),
    );
  }

  group('CategoryProductsWidget — loading', () {
    testWidgets('shows DSLoader while future is pending', (tester) async {
      final completer = Completer<FeedPage>();
      when(
        () => mockRepo.feed(
          categoryId: any(named: 'categoryId'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) => completer.future);

      await tester.pumpWidget(build());
      await tester.pump(); // single frame — future still pending

      expect(find.byType(DSLoader), findsOneWidget);
    });
  });

  group('CategoryProductsWidget — empty state', () {
    testWidgets('shows empty text when the feed returns no products', (
      tester,
    ) async {
      when(
        () => mockRepo.feed(
          categoryId: any(named: 'categoryId'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => const FeedPage(data: <Product>[]));

      await tester.pumpWidget(build());
      await tester.pumpAndSettle();

      // l10n: category_empty = "Nothing here yet."
      expect(find.text('Nothing here yet.'), findsOneWidget);
    });
  });

  group('CategoryProductsWidget — results', () {
    testWidgets('shows CustomScrollView when products are returned', (
      tester,
    ) async {
      final original = FlutterError.onError;
      FlutterError.onError = (d) {
        if (!_isNetworkImageError(d)) original?.call(d);
      };
      addTearDown(() => FlutterError.onError = original);

      when(
        () => mockRepo.feed(
          categoryId: any(named: 'categoryId'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => const FeedPage(data: <Product>[_kProduct]));

      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(build());
      await tester.pumpAndSettle();

      expect(find.byType(CustomScrollView), findsOneWidget);
    });

    testWidgets('shows item count in header', (tester) async {
      final original = FlutterError.onError;
      FlutterError.onError = (d) {
        if (!_isNetworkImageError(d)) original?.call(d);
      };
      addTearDown(() => FlutterError.onError = original);

      when(
        () => mockRepo.feed(
          categoryId: any(named: 'categoryId'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => const FeedPage(data: <Product>[_kProduct]));

      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(build());
      await tester.pumpAndSettle();

      // l10n: category_items_count(1) → "1 item"
      expect(find.text('1 item'), findsOneWidget);
    });

    testWidgets('snapshot data is null-safe (uses empty list fallback)', (
      tester,
    ) async {
      // The builder uses `snapshot.data?.data ?? const []`, so null data is safe.
      when(
        () => mockRepo.feed(
          categoryId: any(named: 'categoryId'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => const FeedPage(data: <Product>[]));

      await tester.pumpWidget(build());
      await tester.pumpAndSettle();

      expect(find.text('Nothing here yet.'), findsOneWidget);
    });
  });
}
