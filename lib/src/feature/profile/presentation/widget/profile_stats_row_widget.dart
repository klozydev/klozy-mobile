import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';

class ProfileStatsRowWidget extends StatelessWidget {
  final int followersCount;
  final int followingCount;

  const ProfileStatsRowWidget({
    super.key,
    required this.followersCount,
    required this.followingCount,
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
          ),
          const VerticalDivider(
            width: DSSpacing.xl,
            thickness: 1,
            color: DSColor.onSurface45,
          ),
          _StatColumn(
            count: followingCount,
            label: context.l10N.profile_stat_following,
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final int count;
  final String label;

  const _StatColumn({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}
