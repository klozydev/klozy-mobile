import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/components/ds_network_image/ds_network_image.dart';
import 'package:klozy/src/domain/product/entity/product.dart';
import 'package:klozy/src/feature/reels/domain/reels_repository.dart';
import 'package:klozy/src/feature/reels/presentation/widget/reel_shop_sheet.dart';
import 'package:klozy/src/router/app_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../support/ds_harness.dart';

class _MockReelsRepository extends Mock implements ReelsRepository {}

class _MockStackRouter extends Mock implements StackRouter {}

// ignore: avoid_implementing_value_types
class _FakeRoute extends Fake implements PageRouteInfo<Object?> {}

// Suppress network image errors from product covers.
bool _isNetworkImageError(FlutterErrorDetails d) {
  final String msg = d.exception.toString();
  return msg.contains('HTTP request failed') ||
      msg.contains('NetworkImageLoadException') ||
      msg.contains('SocketException') ||
      msg.contains('ClientException');
}

const _kProduct = Product(
  id: 'p1',
  title: 'Cool Shirt',
  price: 99,
  brand: 'Brand A',
  size: 'M',
);

const _kProductWithImage = Product(
  id: 'p2',
  title: 'Nice Dress',
  price: 149,
  coverImageUrl: 'https://example.com/img.jpg',
);

void main() {
  late _MockReelsRepository mockRepo;
  late _MockStackRouter router;
  void Function(FlutterErrorDetails)? originalErrorHandler;

  setUpAll(() {
    disableDsFonts();
    registerFallbackValue(_FakeRoute());
    registerFallbackValue(const <PageRouteInfo<Object?>>[]);
  });

  setUp(() async {
    mockRepo = _MockReelsRepository();
    router = _MockStackRouter();

    await GetIt.I.reset();
    GetIt.I.registerSingleton<ReelsRepository>(mockRepo);

    when(() => router.push(any())).thenAnswer((_) async => null);
    when(() => router.navigate(any())).thenAnswer((_) async {});

    originalErrorHandler = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails d) {
      if (_isNetworkImageError(d)) return;
      originalErrorHandler?.call(d);
    };
  });

  tearDown(() async {
    FlutterError.onError = originalErrorHandler;
    await GetIt.I.reset();
  });

  Widget wrap(Widget child) => dsWrapRouted(child, router: router);

  group('ReelShopSheet — loading state', () {
    testWidgets('shows DSLoader while fetching products', (
      WidgetTester tester,
    ) async {
      final Completer<List<Product>> completer = Completer<List<Product>>();
      when(
        () => mockRepo.shopTheLook(any()),
      ).thenAnswer((_) => completer.future);

      await tester.pumpWidget(wrap(const ReelShopSheet(reelId: 'r1')));
      await tester.pump();

      expect(find.byType(DSLoader), findsOneWidget);
    });
  });

  group('ReelShopSheet — empty state', () {
    testWidgets('shows empty message when no tagged products', (
      WidgetTester tester,
    ) async {
      when(
        () => mockRepo.shopTheLook(any()),
      ).thenAnswer((_) async => const <Product>[]);

      await tester.pumpWidget(wrap(const ReelShopSheet(reelId: 'r1')));
      await tester.pumpAndSettle();

      expect(find.byType(DSLoader), findsNothing);
      expect(find.byType(Text), findsWidgets);
    });
  });

  group('ReelShopSheet — populated state', () {
    testWidgets('renders product rows for each product', (
      WidgetTester tester,
    ) async {
      when(
        () => mockRepo.shopTheLook(any()),
      ).thenAnswer((_) async => const <Product>[_kProduct, _kProductWithImage]);

      await tester.pumpWidget(wrap(const ReelShopSheet(reelId: 'r1')));
      // _kProductWithImage has a coverImageUrl → its DSNetworkImage shimmer
      // placeholder animates indefinitely, so pumpAndSettle never settles.
      // Bounded pumps let the repo Future resolve and the list rebuild.
      await tester.pump();
      await tester.pump();

      expect(find.text('Cool Shirt'), findsOneWidget);
      expect(find.text('Nice Dress'), findsOneWidget);

      // Unmount and flush so the still-animating shimmer leaves no pending
      // timer at teardown.
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('shows product price', (WidgetTester tester) async {
      when(
        () => mockRepo.shopTheLook(any()),
      ).thenAnswer((_) async => const <Product>[_kProduct]);

      await tester.pumpWidget(wrap(const ReelShopSheet(reelId: 'r1')));
      await tester.pumpAndSettle();

      // Price is formatted with the l10n key cart_price_dhs(99)
      expect(find.textContaining('99'), findsWidgets);
    });

    testWidgets('shows placeholder when coverImageUrl is null', (
      WidgetTester tester,
    ) async {
      when(
        () => mockRepo.shopTheLook(any()),
      ).thenAnswer((_) async => const <Product>[_kProduct]);

      await tester.pumpWidget(wrap(const ReelShopSheet(reelId: 'r1')));
      await tester.pumpAndSettle();

      // No NetworkImage — finds at least one ColoredBox (the placeholder).
      expect(find.byType(ColoredBox), findsAtLeastNWidgets(1));
    });

    testWidgets('shows DSNetworkImage when coverImageUrl is present', (
      WidgetTester tester,
    ) async {
      when(
        () => mockRepo.shopTheLook(any()),
      ).thenAnswer((_) async => const <Product>[_kProductWithImage]);

      await tester.pumpWidget(wrap(const ReelShopSheet(reelId: 'r1')));
      // Real network fetches never resolve in tests and the shimmer
      // placeholder animates indefinitely, so pumpAndSettle never settles.
      await tester.pump();
      await tester.pump();

      final Finder imageFinder = find.byType(DSNetworkImage);
      expect(imageFinder, findsOneWidget);
      expect(
        tester.widget<DSNetworkImage>(imageFinder).imageUrl,
        _kProductWithImage.coverImageUrl,
      );

      // Unmount and flush so the still-animating shimmer leaves no pending
      // timer at teardown.
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('tapping a product row navigates to ProductRoute', (
      WidgetTester tester,
    ) async {
      when(
        () => mockRepo.shopTheLook(any()),
      ).thenAnswer((_) async => const <Product>[_kProduct]);

      await tester.pumpWidget(wrap(const ReelShopSheet(reelId: 'r1')));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();

      final captured = verify(() => router.push(captureAny())).captured;
      expect(captured.single, isA<ProductRoute>());
    });
  });
}
