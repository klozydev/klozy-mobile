import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/design/components/ds_attribute_chip.dart';
import 'package:klozy/src/domain/product/entity/product_detail.dart';
import 'package:klozy/src/feature/product/presentation/widget/product_title_block_widget.dart';

import '../../../support/ds_harness.dart';

const _kSeller = ProductSeller(id: 's1', displayName: 'Seller');

void main() {
  setUpAll(disableDsFonts);

  group('ProductTitleBlockWidget', () {
    testWidgets('shows product title', (WidgetTester tester) async {
      const detail = ProductDetail(
        id: 'p1',
        title: 'Vintage Jacket',
        price: 150,
        seller: _kSeller,
      );
      await tester.pumpWidget(
        dsWrap(
          const ProductTitleBlockWidget(product: detail),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(find.text('Vintage Jacket'), findsOneWidget);
    });

    testWidgets('shows formatted price with Dhs', (WidgetTester tester) async {
      const detail = ProductDetail(
        id: 'p1',
        title: 'T-Shirt',
        price: 75,
        seller: _kSeller,
      );
      await tester.pumpWidget(
        dsWrap(
          const ProductTitleBlockWidget(product: detail),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(find.text('75 Dhs'), findsOneWidget);
    });

    testWidgets('shows brand chip when brand is set', (
      WidgetTester tester,
    ) async {
      const detail = ProductDetail(
        id: 'p1',
        title: 'Sneakers',
        price: 200,
        seller: _kSeller,
        brand: 'Nike',
      );
      await tester.pumpWidget(
        dsWrap(
          const ProductTitleBlockWidget(product: detail),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(find.byType(DSAttributeChip), findsAtLeastNWidgets(1));
      expect(find.text('Nike'), findsOneWidget);
    });

    testWidgets('shows size chip when size is set', (
      WidgetTester tester,
    ) async {
      const detail = ProductDetail(
        id: 'p1',
        title: 'Jeans',
        price: 120,
        seller: _kSeller,
        size: 'M',
      );
      await tester.pumpWidget(
        dsWrap(
          const ProductTitleBlockWidget(product: detail),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(find.text('M'), findsOneWidget);
    });

    testWidgets('shows Your listing badge when isOwner is true', (
      WidgetTester tester,
    ) async {
      const detail = ProductDetail(
        id: 'p1',
        title: 'My Hat',
        price: 30,
        seller: _kSeller,
        isOwner: true,
      );
      await tester.pumpWidget(
        dsWrap(
          const ProductTitleBlockWidget(product: detail),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(find.text('Your listing'), findsOneWidget);
    });

    testWidgets('hides Your listing badge when isOwner is false', (
      WidgetTester tester,
    ) async {
      const detail = ProductDetail(
        id: 'p1',
        title: 'Coat',
        price: 300,
        seller: _kSeller,
        isOwner: false,
      );
      await tester.pumpWidget(
        dsWrap(
          const ProductTitleBlockWidget(product: detail),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(find.text('Your listing'), findsNothing);
    });
  });
}
