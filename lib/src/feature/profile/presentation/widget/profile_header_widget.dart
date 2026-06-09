import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_star_rating.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/domain/social/entity/social_profile.dart';

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
      children: <Widget>[
        CircleAvatar(
          radius: 44,
          backgroundColor: DSColor.lowBlack,
          backgroundImage: profile.avatarUrl == null
              ? null
              : NetworkImage(profile.avatarUrl!),
          child: profile.avatarUrl == null
              ? const Icon(Icons.person, size: 44, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: Text(
                profile.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: dsFontFamily,
                  fontSize: 20,
                  fontWeight: DSFontWeight.bold,
                  color: DSColor.onSurface,
                ),
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
        ),
        if (profile.handle.isNotEmpty) ...<Widget>[
          const SizedBox(height: 2),
          Text(
            '@${profile.handle}',
            style: const TextStyle(
              fontFamily: dsFontFamily,
              fontSize: DSFontSize.bodyMedium,
              color: DSColor.onSurface45,
            ),
          ),
        ],
        const SizedBox(height: 8),
        GestureDetector(
          onTap: profile.reviewCount > 0 ? onRatingTap : null,
          child: profile.reviewCount > 0
              ? DSStarRating(
                  rating: profile.rating,
                  reviewCount: profile.reviewCount,
                  starSize: 13,
                )
              : Text(
                  context.l10N.profile_no_reviews,
                  style: const TextStyle(
                    fontFamily: dsFontFamily,
                    fontSize: DSFontSize.bodySmall,
                    color: DSColor.onSurface35,
                  ),
                ),
        ),
        if (profile.bio != null && profile.bio!.isNotEmpty) ...<Widget>[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              profile.bio!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: dsFontFamily,
                fontSize: DSFontSize.bodyMedium,
                height: 1.4,
                color: DSColor.onSurface75,
              ),
            ),
          ),
        ],
        if (profile.location != null &&
            profile.location!.isNotEmpty) ...<Widget>[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: DSColor.onSurface45,
              ),
              const SizedBox(width: 4),
              Text(
                profile.location!,
                style: const TextStyle(
                  fontFamily: dsFontFamily,
                  fontSize: DSFontSize.bodyMedium,
                  color: DSColor.onSurface60,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _stat(
              '${profile.listingsCount}',
              context.l10N.profile_stat_listings,
              null,
            ),
            _divider(),
            _stat(
              '${profile.followers}',
              context.l10N.profile_stat_followers,
              onFollowers,
            ),
            _divider(),
            _stat(
              '${profile.following}',
              context.l10N.profile_stat_following,
              onFollowing,
            ),
          ],
        ),
      ],
    );
  }

  Widget _stat(String value, String label, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        child: Column(
          children: <Widget>[
            Text(
              value,
              style: const TextStyle(
                fontFamily: dsFontFamily,
                fontSize: DSFontSize.bodyLarge,
                fontWeight: DSFontWeight.bold,
                color: DSColor.onSurface,
              ),
            ),
            const SizedBox(height: 2),
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

  Widget _divider() {
    return Container(width: 0.5, height: 28, color: DSColor.onSurface15);
  }
}
