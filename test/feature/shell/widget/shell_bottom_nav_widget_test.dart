import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/feature/shell/presentation/widget/shell_bottom_nav_widget.dart';
import 'package:klozy/src/feature/shell/presentation/widget/shell_nav_item_widget.dart';
import 'package:klozy/src/feature/shell/presentation/widget/shell_sell_fab_widget.dart';

import '../../../support/ds_harness.dart';

/// Reads the asset path backing an [SvgPicture.asset], or `null` for other
/// loaders.
String? _svgAsset(SvgPicture svg) {
  final BytesLoader loader = svg.bytesLoader;
  return loader is SvgAssetLoader ? loader.assetName : null;
}

/// Finds the [SvgPicture] whose asset path matches [path].
Finder _svgByAsset(String path) => find.byWidgetPredicate(
  (Widget w) => w is SvgPicture && _svgAsset(w) == path,
);

void main() {
  setUpAll(disableDsFonts);

  group('ShellNavItemWidget', () {
    testWidgets('renders the given SVG asset at 24x24', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        dsWrap(
          ShellNavItemWidget(
            assetPath: 'assets/svg/ic_home.svg',
            active: false,
            onTap: () {},
          ),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      final SvgPicture svg = tester.widget<SvgPicture>(
        _svgByAsset('assets/svg/ic_home.svg'),
      );
      expect(svg.width, 24);
      expect(svg.height, 24);
    });

    testWidgets('uses the gold primary color filter when active', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        dsWrap(
          ShellNavItemWidget(
            assetPath: 'assets/svg/ic_home.svg',
            active: true,
            onTap: () {},
          ),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      final SvgPicture svg = tester.widget<SvgPicture>(
        _svgByAsset('assets/svg/ic_home.svg'),
      );
      expect(
        svg.colorFilter,
        const ColorFilter.mode(DSColor.primary, BlendMode.srcIn),
      );
    });

    testWidgets('uses the muted color filter when inactive', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        dsWrap(
          ShellNavItemWidget(
            assetPath: 'assets/svg/ic_home.svg',
            active: false,
            onTap: () {},
          ),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      final SvgPicture svg = tester.widget<SvgPicture>(
        _svgByAsset('assets/svg/ic_home.svg'),
      );
      expect(
        svg.colorFilter,
        const ColorFilter.mode(DSColor.onSurface45, BlendMode.srcIn),
      );
    });

    testWidgets('invokes onTap when tapped', (WidgetTester tester) async {
      var tapped = false;
      await tester.pumpWidget(
        dsWrap(
          ShellNavItemWidget(
            assetPath: 'assets/svg/ic_search.svg',
            active: false,
            onTap: () => tapped = true,
          ),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      await tester.tap(_svgByAsset('assets/svg/ic_search.svg'));
      expect(tapped, isTrue);
    });

    testWidgets('shows the badge count when badge > 0', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        dsWrap(
          ShellNavItemWidget(
            assetPath: 'assets/svg/ic_tchat.svg',
            active: false,
            onTap: () {},
            badge: 3,
          ),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('caps the badge at 9+', (WidgetTester tester) async {
      await tester.pumpWidget(
        dsWrap(
          ShellNavItemWidget(
            assetPath: 'assets/svg/ic_tchat.svg',
            active: false,
            onTap: () {},
            badge: 42,
          ),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(find.text('9+'), findsOneWidget);
    });

    testWidgets('hides the badge when badge is 0', (WidgetTester tester) async {
      await tester.pumpWidget(
        dsWrap(
          ShellNavItemWidget(
            assetPath: 'assets/svg/ic_tchat.svg',
            active: false,
            onTap: () {},
          ),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(find.text('0'), findsNothing);
    });
  });

  group('ShellBottomNavWidget', () {
    Widget buildBar({
      int activeIndex = 0,
      ValueChanged<int>? onTab,
      VoidCallback? onSell,
      int chatBadge = 0,
    }) {
      return dsWrap(
        ShellBottomNavWidget(
          activeIndex: activeIndex,
          onTab: onTab ?? (_) {},
          onSell: onSell ?? () {},
          chatBadge: chatBadge,
        ),
        wrapInScaffold: true,
      );
    }

    testWidgets('renders the four legacy tab SVGs plus the Sell FAB', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildBar());
      await tester.pump();

      expect(find.byType(ShellNavItemWidget), findsNWidgets(4));
      expect(find.byType(ShellSellFabWidget), findsOneWidget);
      expect(_svgByAsset('assets/svg/ic_home.svg'), findsOneWidget);
      expect(_svgByAsset('assets/svg/ic_search.svg'), findsOneWidget);
      expect(_svgByAsset('assets/svg/ic_tchat.svg'), findsOneWidget);
      expect(_svgByAsset('assets/svg/ic_profile.svg'), findsOneWidget);
      expect(_svgByAsset('assets/svg/ic_add.svg'), findsOneWidget);
    });

    testWidgets('taps map to the expected tab indices', (
      WidgetTester tester,
    ) async {
      final List<int> taps = <int>[];
      await tester.pumpWidget(buildBar(onTab: taps.add));
      await tester.pump();

      await tester.tap(_svgByAsset('assets/svg/ic_home.svg'));
      await tester.tap(_svgByAsset('assets/svg/ic_search.svg'));
      await tester.tap(_svgByAsset('assets/svg/ic_tchat.svg'));
      await tester.tap(_svgByAsset('assets/svg/ic_profile.svg'));

      expect(taps, <int>[0, 1, 2, 3]);
    });

    testWidgets('tapping the FAB invokes onSell, not onTab', (
      WidgetTester tester,
    ) async {
      var sold = false;
      var tabbed = false;
      await tester.pumpWidget(
        buildBar(onTab: (_) => tabbed = true, onSell: () => sold = true),
      );
      await tester.pump();

      await tester.tap(_svgByAsset('assets/svg/ic_add.svg'));
      expect(sold, isTrue);
      expect(tabbed, isFalse);
    });

    testWidgets('highlights only the active tab in gold', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildBar(activeIndex: 1));
      await tester.pump();

      SvgPicture svgFor(String path) =>
          tester.widget<SvgPicture>(_svgByAsset(path));

      expect(
        svgFor('assets/svg/ic_search.svg').colorFilter,
        const ColorFilter.mode(DSColor.primary, BlendMode.srcIn),
      );
      expect(
        svgFor('assets/svg/ic_home.svg').colorFilter,
        const ColorFilter.mode(DSColor.onSurface45, BlendMode.srcIn),
      );
    });

    testWidgets('forwards the chat badge to the chat tab', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildBar(chatBadge: 5));
      await tester.pump();

      expect(find.text('5'), findsOneWidget);
    });
  });
}
