import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';
import 'package:klozy/src/domain/social/entity/profile_reel.dart';
import 'package:klozy/src/feature/profile/presentation/widget/profile_reel_tile_widget.dart';
import 'package:klozy/src/feature/profile/presentation/widget/profile_tab_empty.dart';

/// Sliver form of the Reels tab grid, for use inside a `CustomScrollView` so
/// pull-to-refresh and infinite scroll keep working even when the grid is
/// shorter than the viewport. Mirrors `ProfileReelsGrid`'s delegate and card
/// visuals (via [ProfileReelTileWidget]).
class ProfileReelsSliverGrid extends StatelessWidget {
  final List<ProfileReel> reels;
  final ValueChanged<ProfileReel> onTap;

  const ProfileReelsSliverGrid({
    super.key,
    required this.reels,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (reels.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: ProfileTabEmpty(
          icon: Icons.movie_outlined,
          label: context.l10N.profile_no_reels,
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        DSSpacing.s,
        DSSpacing.s,
        DSSpacing.s,
        DSSpacing.l,
      ),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
          childAspectRatio: 9 / 16,
        ),
        delegate: SliverChildBuilderDelegate((BuildContext context, int i) {
          final ProfileReel reel = reels[i];
          return ProfileReelTileWidget(reel: reel, onTap: () => onTap(reel));
        }, childCount: reels.length),
      ),
    );
  }
}
