import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/product/entity/product_detail.dart';
import 'package:klozy/src/feature/product/presentation/widget/product_owner_stats_widget.dart';

import '../../../support/ds_harness.dart';

const _kSeller = ProductSeller(id: 's1', displayName: 'Seller');

void main() {
  setUpAll(disableDsFonts);

  group('ProductOwnerStatsWidget', () {
    const detail = ProductDetail(
      id: 'p1',
      title: 'Jacket',
      price: 200,
      seller: _kSeller,
      views: 42,
      likes: 7,
      postedLabel: '2 days ago',
    );

    testWidgets('shows Views label', (WidgetTester tester) async {
      await tester.pumpWidget(
        dsWrap(
          const ProductOwnerStatsWidget(detail: detail),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(find.text('Views'), findsOneWidget);
    });

    testWidgets('shows Likes label', (WidgetTester tester) async {
      await tester.pumpWidget(
        dsWrap(
          const ProductOwnerStatsWidget(detail: detail),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(find.text('Likes'), findsOneWidget);
    });

    testWidgets('shows Posted label', (WidgetTester tester) async {
      await tester.pumpWidget(
        dsWrap(
          const ProductOwnerStatsWidget(detail: detail),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(find.text('Posted'), findsOneWidget);
    });

    testWidgets('shows correct view count', (WidgetTester tester) async {
      await tester.pumpWidget(
        dsWrap(
          const ProductOwnerStatsWidget(detail: detail),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('shows correct likes count', (WidgetTester tester) async {
      await tester.pumpWidget(
        dsWrap(
          const ProductOwnerStatsWidget(detail: detail),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('shows postedLabel value in posted stat', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        dsWrap(
          const ProductOwnerStatsWidget(detail: detail),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(find.text('2 days ago'), findsOneWidget);
    });

    testWidgets('shows dash when postedLabel is null', (
      WidgetTester tester,
    ) async {
      const noPosted = ProductDetail(
        id: 'p2',
        title: 'Shoes',
        price: 80,
        seller: _kSeller,
      );
      await tester.pumpWidget(
        dsWrap(
          const ProductOwnerStatsWidget(detail: noPosted),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(find.text('—'), findsOneWidget);
    });
  });
}
