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
            icon: Icons.home_outlined,
            active: activeIndex == 0,
            onTap: () => onTab(0),
          ),
          ShellNavItemWidget(
            icon: Icons.search_rounded,
            active: activeIndex == 1,
            onTap: () => onTab(1),
          ),
          ShellSellFabWidget(onTap: onSell),
          ShellNavItemWidget(
            icon: Icons.chat_bubble_outline_rounded,
            active: activeIndex == 2,
            onTap: () => onTab(2),
            badge: chatBadge,
          ),
          ShellNavItemWidget(
            icon: Icons.person_outline_rounded,
            active: activeIndex == 3,
            onTap: () => onTab(3),
          ),
        ],
      ),
    );
  }
}
