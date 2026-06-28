import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/reels/presentation/widget/reel_menu_sheet.dart';

import '../../../../support/ds_harness.dart';

void main() {
  setUpAll(disableDsFonts);

  group('ReelMenuSheet — owner mode', () {
    testWidgets('shows Edit, Share and Delete when isOwner=true with onEdit', (
      WidgetTester tester,
    ) async {
      bool editCalled = false;
      bool shareCalled = false;
      bool deleteCalled = false;
      bool reportCalled = false;

      await tester.pumpWidget(
        dsWrap(
          ReelMenuSheet(
            isOwner: true,
            onEdit: () => editCalled = true,
            onShare: () => shareCalled = true,
            onDelete: () => deleteCalled = true,
            onReport: () => reportCalled = true,
          ),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      // Owner rows: Edit, Share, Delete (3 InkWell rows)
      expect(find.byType(InkWell), findsNWidgets(3));
      _ = editCalled;
      _ = shareCalled;
      _ = deleteCalled;
      _ = reportCalled;
    });

    testWidgets('tapping Edit calls onEdit', (WidgetTester tester) async {
      bool editCalled = false;

      await tester.pumpWidget(
        dsWrap(
          ReelMenuSheet(
            isOwner: true,
            onEdit: () => editCalled = true,
            onShare: () {},
            onDelete: () {},
            onReport: () {},
          ),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      await tester.tap(find.byType(InkWell).first);
      expect(editCalled, isTrue);
    });

    testWidgets('tapping Share calls onShare (owner)', (
      WidgetTester tester,
    ) async {
      bool shareCalled = false;

      await tester.pumpWidget(
        dsWrap(
          ReelMenuSheet(
            isOwner: true,
            onEdit: () {},
            onShare: () => shareCalled = true,
            onDelete: () {},
            onReport: () {},
          ),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      // Share is second InkWell
      await tester.tap(find.byType(InkWell).at(1));
      expect(shareCalled, isTrue);
    });

    testWidgets('tapping Delete calls onDelete', (WidgetTester tester) async {
      bool deleteCalled = false;

      await tester.pumpWidget(
        dsWrap(
          ReelMenuSheet(
            isOwner: true,
            onEdit: () {},
            onShare: () {},
            onDelete: () => deleteCalled = true,
            onReport: () {},
          ),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      // Delete is third InkWell
      await tester.tap(find.byType(InkWell).at(2));
      expect(deleteCalled, isTrue);
    });

    testWidgets('hides Edit row when onEdit is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        dsWrap(
          ReelMenuSheet(
            isOwner: true,
            onEdit: null,
            onShare: () {},
            onDelete: () {},
            onReport: () {},
          ),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      // Only Share + Delete — 2 InkWells
      expect(find.byType(InkWell), findsNWidgets(2));
    });
  });

  group('ReelMenuSheet — non-owner mode', () {
    testWidgets('shows Share and Report when isOwner=false', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        dsWrap(
          ReelMenuSheet(
            isOwner: false,
            onShare: () {},
            onDelete: () {},
            onReport: () {},
          ),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      // Non-owner rows: Share, Report (2 InkWell rows)
      expect(find.byType(InkWell), findsNWidgets(2));
    });

    testWidgets('tapping Share calls onShare (non-owner)', (
      WidgetTester tester,
    ) async {
      bool shareCalled = false;

      await tester.pumpWidget(
        dsWrap(
          ReelMenuSheet(
            isOwner: false,
            onShare: () => shareCalled = true,
            onDelete: () {},
            onReport: () {},
          ),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      await tester.tap(find.byType(InkWell).first);
      expect(shareCalled, isTrue);
    });

    testWidgets('tapping Report calls onReport', (WidgetTester tester) async {
      bool reportCalled = false;

      await tester.pumpWidget(
        dsWrap(
          ReelMenuSheet(
            isOwner: false,
            onShare: () {},
            onDelete: () {},
            onReport: () => reportCalled = true,
          ),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      // Report is second InkWell
      await tester.tap(find.byType(InkWell).at(1));
      expect(reportCalled, isTrue);
    });
  });
}
