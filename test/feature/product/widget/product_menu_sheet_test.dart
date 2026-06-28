import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/product/presentation/widget/product_menu_sheet.dart';

import '../../../support/ds_harness.dart';

void main() {
  setUpAll(disableDsFonts);

  group('ProductMenuSheet', () {
    group('owner mode', () {
      testWidgets('shows Edit listing action', (WidgetTester tester) async {
        await tester.pumpWidget(
          dsWrap(
            ProductMenuSheet(
              isOwner: true,
              onEdit: () {},
              onDelete: () {},
              onReport: () {},
            ),
            wrapInScaffold: true,
          ),
        );
        await tester.pump();

        expect(find.text('Edit listing'), findsOneWidget);
      });

      testWidgets('shows Delete listing action', (WidgetTester tester) async {
        await tester.pumpWidget(
          dsWrap(
            ProductMenuSheet(
              isOwner: true,
              onEdit: () {},
              onDelete: () {},
              onReport: () {},
            ),
            wrapInScaffold: true,
          ),
        );
        await tester.pump();

        expect(find.text('Delete listing'), findsOneWidget);
      });

      testWidgets('does not show Report listing action', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          dsWrap(
            ProductMenuSheet(
              isOwner: true,
              onEdit: () {},
              onDelete: () {},
              onReport: () {},
            ),
            wrapInScaffold: true,
          ),
        );
        await tester.pump();

        expect(find.text('Report listing'), findsNothing);
      });

      testWidgets('onEdit fires when Edit listing is tapped', (
        WidgetTester tester,
      ) async {
        var editCalled = false;
        await tester.pumpWidget(
          dsWrap(
            ProductMenuSheet(
              isOwner: true,
              onEdit: () => editCalled = true,
              onDelete: () {},
              onReport: () {},
            ),
            wrapInScaffold: true,
          ),
        );
        await tester.pump();

        await tester.tap(find.text('Edit listing'));
        await tester.pump();

        expect(editCalled, isTrue);
      });

      testWidgets('onDelete fires when Delete listing is tapped', (
        WidgetTester tester,
      ) async {
        var deleteCalled = false;
        await tester.pumpWidget(
          dsWrap(
            ProductMenuSheet(
              isOwner: true,
              onEdit: () {},
              onDelete: () => deleteCalled = true,
              onReport: () {},
            ),
            wrapInScaffold: true,
          ),
        );
        await tester.pump();

        await tester.tap(find.text('Delete listing'));
        await tester.pump();

        expect(deleteCalled, isTrue);
      });
    });

    group('non-owner mode', () {
      testWidgets('shows Report listing action', (WidgetTester tester) async {
        await tester.pumpWidget(
          dsWrap(
            ProductMenuSheet(
              isOwner: false,
              onEdit: () {},
              onDelete: () {},
              onReport: () {},
            ),
            wrapInScaffold: true,
          ),
        );
        await tester.pump();

        expect(find.text('Report listing'), findsOneWidget);
      });

      testWidgets('does not show Edit or Delete actions', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          dsWrap(
            ProductMenuSheet(
              isOwner: false,
              onEdit: () {},
              onDelete: () {},
              onReport: () {},
            ),
            wrapInScaffold: true,
          ),
        );
        await tester.pump();

        expect(find.text('Edit listing'), findsNothing);
        expect(find.text('Delete listing'), findsNothing);
      });

      testWidgets('onReport fires when Report listing is tapped', (
        WidgetTester tester,
      ) async {
        var reportCalled = false;
        await tester.pumpWidget(
          dsWrap(
            ProductMenuSheet(
              isOwner: false,
              onEdit: () {},
              onDelete: () {},
              onReport: () => reportCalled = true,
            ),
            wrapInScaffold: true,
          ),
        );
        await tester.pump();

        await tester.tap(find.text('Report listing'));
        await tester.pump();

        expect(reportCalled, isTrue);
      });
    });
  });
}
