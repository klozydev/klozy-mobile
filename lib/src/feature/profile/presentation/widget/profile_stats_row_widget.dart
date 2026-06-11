import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';

class ProfileStatsRowWidget extends StatelessWidget {
  final int followersCount;
  final int followingCount;
  final VoidCallback? onFollowers;
  final VoidCallback? onFollowing;

  const ProfileStatsRowWidget({
    super.key,
    required this.followersCount,
    required this.followingCount,
    this.onFollowers,
    this.onFollowing,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _StatColumn(
            count: followersCount,
            label: context.l10N.profile_stat_followers,
            onTap: onFollowers,
          ),
          const VerticalDivider(
            width: DSSpacing.xl,
            thickness: 1,
            color: DSColor.onSurface45,
          ),
          _StatColumn(
            count: followingCount,
            label: context.l10N.profile_stat_following,
            onTap: onFollowing,
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final int count;
  final String label;
  final VoidCallback? onTap;

  const _StatColumn({required this.count, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            count.toString(),
            style: const TextStyle(
              fontFamily: dsFontFamily,
              fontSize: DSFontSize.headlineLarge,
              fontWeight: DSFontWeight.bold,
              color: DSColor.onSurface,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontFamily: dsFontFamily,
              fontSize: DSFontSize.bodySmall,
              color: DSColor.onSurface45,
            ),
          ),
        ],
      ),
    );
  }
}
