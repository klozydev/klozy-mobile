import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/product/entity/product_detail.dart';
import 'package:klozy/src/feature/product/presentation/widget/product_carousel_widget.dart';

import '../../../support/ds_harness.dart';

void main() {
  setUpAll(disableDsFonts);

  group('ProductCarouselWidget', () {
    testWidgets('renders without crash with empty images', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        dsWrap(
          const ProductCarouselWidget(
            images: <String>[],
            status: ProductStatus.active,
          ),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(find.byType(ProductCarouselWidget), findsOneWidget);
    });

    testWidgets('does not show sold stamp for active status', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        dsWrap(
          const ProductCarouselWidget(
            images: <String>[],
            status: ProductStatus.active,
          ),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(find.text('SOLD'), findsNothing);
      expect(find.text('RESERVED'), findsNothing);
    });

    testWidgets('shows SOLD stamp when status is sold', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        dsWrap(
          const ProductCarouselWidget(
            images: <String>[],
            status: ProductStatus.sold,
          ),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(find.text('SOLD'), findsOneWidget);
    });

    testWidgets('shows RESERVED stamp when status is reserved', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        dsWrap(
          const ProductCarouselWidget(
            images: <String>[],
            status: ProductStatus.reserved,
          ),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(find.text('RESERVED'), findsOneWidget);
    });
  });
}
