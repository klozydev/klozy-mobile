import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/product/entity/product_detail.dart';
import 'package:klozy/src/feature/product/presentation/widget/product_detail_meta_row_widget.dart';

import '../../../support/ds_harness.dart';

const _kSeller = ProductSeller(id: 's1', displayName: 'Seller');

ProductDetail _detail({String? location, String? postedLabel}) => ProductDetail(
  id: 'p1',
  title: 'Title',
  price: 50,
  seller: _kSeller,
  location: location,
  postedLabel: postedLabel,
);

void main() {
  setUpAll(disableDsFonts);

  group('ProductDetailMetaRowWidget', () {
    testWidgets('renders nothing when no location and no postedLabel', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        dsWrap(
          ProductDetailMetaRowWidget(product: _detail()),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      // SizedBox.shrink — no Row visible
      expect(find.byType(Row), findsNothing);
    });

    testWidgets('shows location text when location is set', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        dsWrap(
          ProductDetailMetaRowWidget(product: _detail(location: 'Paris')),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(find.text('Paris'), findsOneWidget);
    });

    testWidgets('shows postedLabel text when postedLabel is set', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        dsWrap(
          ProductDetailMetaRowWidget(
            product: _detail(postedLabel: '3 days ago'),
          ),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(find.text('3 days ago'), findsOneWidget);
    });

    testWidgets('shows both chips when both fields are set', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        dsWrap(
          ProductDetailMetaRowWidget(
            product: _detail(location: 'London', postedLabel: '1 week ago'),
          ),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(find.text('London'), findsOneWidget);
      expect(find.text('1 week ago'), findsOneWidget);
    });
  });
}
