import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';

class ProfileTabBarWidget extends StatelessWidget {
  final TabController tabController;

  const ProfileTabBarWidget({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    final List<String> tabs = <String>[
      context.l10N.profile_tab_products,
      context.l10N.profile_tab_reels,
      context.l10N.profile_tab_reviews,
    ];
    return TabBar(
      controller: tabController,
      tabs: tabs.map((String t) => Tab(text: t)).toList(),
      labelColor: DSColor.primary,
      unselectedLabelColor: DSColor.onSurface45,
      indicatorColor: DSColor.primary,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: DSColor.onSurface45.withValues(alpha: 0.3),
    );
  }
}
