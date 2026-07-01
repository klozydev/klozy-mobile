import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/feature/shell/presentation/widget/shell_nav_item_widget.dart';
import 'package:klozy/src/feature/shell/presentation/widget/shell_sell_fab_widget.dart';

/// Persistent 5-slot bottom navigation: Home · Search · Sell (FAB) · Chat ·
/// Profile. The FAB pushes the sell flow; the other four switch tabs.
///
/// [activeIndex] is the active tab index in the order Home(0), Search(1),
/// Chat(2), Profile(3) — the FAB is not a tab.
class ShellBottomNavWidget extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onTab;
  final VoidCallback onSell;
  final int chatBadge;

  const ShellBottomNavWidget({
    super.key,
    required this.activeIndex,
    required this.onTab,
    required this.onSell,
    this.chatBadge = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: DSColor.surface,
        border: Border(top: BorderSide(color: DSColor.onSurface10, width: 0.5)),
      ),
      padding: const EdgeInsets.fromLTRB(4, 9, 4, 22),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          ShellNavItemWidget(
            assetPath: 'assets/svg/ic_home.svg',
            active: activeIndex == 0,
            onTap: () => onTab(0),
          ),
          ShellNavItemWidget(
            assetPath: 'assets/svg/ic_search.svg',
            active: activeIndex == 1,
            onTap: () => onTab(1),
          ),
          ShellSellFabWidget(onTap: onSell),
          ShellNavItemWidget(
            assetPath: 'assets/svg/ic_tchat.svg',
            active: activeIndex == 2,
            onTap: () => onTab(2),
            badge: chatBadge,
          ),
          ShellNavItemWidget(
            assetPath: 'assets/svg/ic_profile.svg',
            active: activeIndex == 3,
            onTap: () => onTab(3),
          ),
        ],
      ),
    );
  }
}
