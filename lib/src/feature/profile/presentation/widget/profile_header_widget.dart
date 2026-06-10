import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/design/components/ds_star_rating.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';
import 'package:klozy/src/domain/social/entity/social_profile.dart';
import 'package:klozy/src/feature/profile/presentation/widget/profile_stats_row_widget.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final SocialProfile profile;
  final VoidCallback onFollowers;
  final VoidCallback onFollowing;
  final VoidCallback onRatingTap;

  const ProfileHeaderWidget({
    super.key,
    required this.profile,
    required this.onFollowers,
    required this.onFollowing,
    required this.onRatingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const SizedBox(height: DSSpacing.l),
        _AvatarWidget(avatarUrl: profile.avatarUrl),
        const SizedBox(height: DSSpacing.m),
        _NameRow(profile: profile),
        const SizedBox(height: DSSpacing.xxs),
        if (profile.reviewCount > 0)
          GestureDetector(
            onTap: onRatingTap,
            child: DSStarRating(
              rating: profile.rating,
              reviewCount: profile.reviewCount,
              starSize: 13,
            ),
          ),
        if (profile.bio != null && profile.bio!.isNotEmpty) ...<Widget>[
          const SizedBox(height: DSSpacing.xxs),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DSSpacing.xl),
            child: Text(
              profile.bio!,
              style: const TextStyle(
                fontFamily: dsFontFamily,
                fontSize: DSFontSize.bodyMedium,
                color: DSColor.onSurface45,
                height: DSFontHeight.bodyMedium,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
        const SizedBox(height: DSSpacing.m),
        ProfileStatsRowWidget(
          followersCount: profile.followers,
          followingCount: profile.following,
        ),
        const SizedBox(height: DSSpacing.l),
      ],
    );
  }
}

class _AvatarWidget extends StatelessWidget {
  final String? avatarUrl;

  const _AvatarWidget({required this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    if (avatarUrl != null) {
      return CircleAvatar(
        radius: 56,
        backgroundColor: DSColor.lowBlack,
        backgroundImage: CachedNetworkImageProvider(avatarUrl!),
      );
    }
    return const CircleAvatar(
      radius: 56,
      backgroundColor: DSColor.lowBlack,
      child: Icon(Icons.person, size: 56, color: DSColor.onSurface45),
    );
  }
}

class _NameRow extends StatelessWidget {
  final SocialProfile profile;

  const _NameRow({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Flexible(
          child: Text(
            profile.name,
            style: const TextStyle(
              fontFamily: dsFontFamily,
              fontSize: DSFontSize.displayLarge,
              fontWeight: DSFontWeight.bold,
              color: DSColor.onSurface,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (profile.isPro) ...<Widget>[
          const SizedBox(width: DSSpacing.xxs),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.xxs - 2,
              vertical: DSSpacing.xxxs - 2,
            ),
            decoration: BoxDecoration(
              color: const Color(0x1FE0CE7D),
              borderRadius: BorderRadius.circular(DSBorderRadius.chip),
            ),
            child: const Text(
              'PRO',
              style: TextStyle(
                fontFamily: dsFontFamily,
                fontSize: 9,
                fontWeight: DSFontWeight.bold,
                color: DSColor.primary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
