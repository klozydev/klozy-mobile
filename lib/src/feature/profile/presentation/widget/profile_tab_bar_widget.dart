import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';

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
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: DSColor.onSurface08, width: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: TabBar(
          controller: tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: DSColor.onSurface,
          unselectedLabelColor: DSColor.onSurface45,
          labelStyle: const TextStyle(
            fontFamily: dsFontFamily,
            fontSize: DSFontSize.bodyLarge,
            fontWeight: DSFontWeight.semiBold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: dsFontFamily,
            fontSize: DSFontSize.bodyLarge,
            fontWeight: DSFontWeight.medium,
          ),
          labelPadding: const EdgeInsets.only(right: 22),
          indicatorColor: DSColor.primary,
          indicatorWeight: 2,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: Colors.transparent,
          tabs: tabs.map((String t) => Tab(text: t)).toList(),
        ),
      ),
    );
  }
}
