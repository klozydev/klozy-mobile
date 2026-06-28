import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/home/presentation/widget/shell_tabs_widget.dart';

import '../../../support/ds_harness.dart';

void main() {
  setUpAll(() {
    disableDsFonts();
  });

  const tabs = ['Feed', 'Wishlist', 'Reels'];

  group('ShellTabsWidget', () {
    testWidgets('renders all tab labels', (WidgetTester tester) async {
      await tester.pumpWidget(
        dsWrap(
          ShellTabsWidget(tabs: tabs, selectedIndex: 0, onChanged: (_) {}),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(find.text('Feed'), findsOneWidget);
      expect(find.text('Wishlist'), findsOneWidget);
      expect(find.text('Reels'), findsOneWidget);
    });

    testWidgets('calls onChanged with correct index when tab tapped', (
      WidgetTester tester,
    ) async {
      int? selectedIndex;
      await tester.pumpWidget(
        dsWrap(
          ShellTabsWidget(
            tabs: tabs,
            selectedIndex: 0,
            onChanged: (i) => selectedIndex = i,
          ),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Wishlist'));
      expect(selectedIndex, 1);
    });

    testWidgets('calls onChanged with index 2 when Reels tapped', (
      WidgetTester tester,
    ) async {
      int? selectedIndex;
      await tester.pumpWidget(
        dsWrap(
          ShellTabsWidget(
            tabs: tabs,
            selectedIndex: 0,
            onChanged: (i) => selectedIndex = i,
          ),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Reels'));
      expect(selectedIndex, 2);
    });

    testWidgets('calls onChanged with index 0 when Feed tapped', (
      WidgetTester tester,
    ) async {
      int? selectedIndex;
      await tester.pumpWidget(
        dsWrap(
          ShellTabsWidget(
            tabs: tabs,
            selectedIndex: 1,
            onChanged: (i) => selectedIndex = i,
          ),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Feed'));
      expect(selectedIndex, 0);
    });

    testWidgets('renders without crashing in overlay mode', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        dsWrap(
          ShellTabsWidget(
            tabs: tabs,
            selectedIndex: 2,
            onChanged: (_) {},
            overlay: true,
          ),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(find.text('Feed'), findsOneWidget);
      expect(find.text('Wishlist'), findsOneWidget);
      expect(find.text('Reels'), findsOneWidget);
    });
  });
}
