import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';

class ProfileStatsRowWidget extends StatelessWidget {
  final int followersCount;
  final int followingCount;
  final VoidCallback onFollowers;
  final VoidCallback onFollowing;

  const ProfileStatsRowWidget({
    super.key,
    required this.followersCount,
    required this.followingCount,
    required this.onFollowers,
    required this.onFollowing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _StatColumn(
          count: followersCount,
          label: context.l10N.profile_stat_followers,
          onTap: onFollowers,
        ),
        Container(width: 0.5, height: 28, color: DSColor.onSurface12),
        _StatColumn(
          count: followingCount,
          label: context.l10N.profile_stat_following,
          onTap: onFollowing,
        ),
      ],
    );
  }
}

class _StatColumn extends StatelessWidget {
  final int count;
  final String label;
  final VoidCallback onTap;

  const _StatColumn({
    required this.count,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              NumberFormat.decimalPattern().format(count),
              style: const TextStyle(
                fontFamily: dsFontFamily,
                fontSize: DSFontSize.titleLarge,
                fontWeight: DSFontWeight.bold,
                color: DSColor.onSurface,
              ),
            ),
            const SizedBox(height: 1),
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
      ),
    );
  }
}
