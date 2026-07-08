import 'package:flutter/material.dart';
import 'package:klozy/src/design/components/ds_network_image/ds_network_image.dart';
import 'package:klozy/src/design/components/ds_network_image/ds_network_image_shape.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/domain/social/entity/social_profile.dart';
import 'package:klozy/src/feature/profile/presentation/widget/profile_rating_summary.dart';
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
        const SizedBox(height: 8),
        _AvatarWidget(avatarUrl: profile.avatarUrl, name: profile.name),
        const SizedBox(height: 14),
        _NameRow(profile: profile),
        const SizedBox(height: 7),
        GestureDetector(
          onTap: onRatingTap,
          child: ProfileRatingSummary(
            rating: profile.rating,
            reviewCount: profile.reviewCount,
          ),
        ),
        if (profile.bio != null && profile.bio!.isNotEmpty) ...<Widget>[
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Text(
              profile.bio!,
              style: const TextStyle(
                fontFamily: dsFontFamily,
                fontSize: DSFontSize.bodyMedium,
                color: DSColor.onSurface65,
                height: 19 / DSFontSize.bodyMedium,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
        const SizedBox(height: 16),
        ProfileStatsRowWidget(
          followersCount: profile.followers,
          followingCount: profile.following,
          onFollowers: onFollowers,
          onFollowing: onFollowing,
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}

class _AvatarWidget extends StatelessWidget {
  final String? avatarUrl;
  final String name;

  const _AvatarWidget({required this.avatarUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    final String initial = name.isEmpty
        ? '?'
        : name.characters.first.toUpperCase();
    return DSNetworkImage(
      imageUrl: avatarUrl,
      width: 88,
      height: 88,
      shape: DSNetworkImageShape.circle,
      fallback: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          color: DSColor.card,
          shape: BoxShape.circle,
          border: Border.all(color: DSColor.onSurface10, width: 1),
        ),
        alignment: Alignment.center,
        child: Text(
          initial,
          style: const TextStyle(
            fontFamily: dsFontFamily,
            fontSize: 30,
            fontWeight: DSFontWeight.bold,
            color: DSColor.onSurface45,
          ),
        ),
      ),
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
              fontSize: DSFontSize.headlineLarge,
              fontWeight: DSFontWeight.bold,
              color: DSColor.onSurface,
              letterSpacing: -0.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (profile.isPro) ...<Widget>[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
