import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_star_rating.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/domain/social/entity/social_profile.dart';
import 'package:klozy/src/domain/social/entity/user_review.dart';
import 'package:klozy/src/feature/profile/presentation/widget/profile_tab_empty.dart';
import 'package:klozy/src/feature/profile/presentation/widget/review_card_widget.dart';

class ProfileReviewsList extends StatelessWidget {
  final SocialProfile profile;
  final List<UserReview> reviews;

  const ProfileReviewsList({
    super.key,
    required this.profile,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty && profile.reviewCount == 0) {
      return ProfileTabEmpty(
        icon: Icons.star_outline_rounded,
        label: context.l10N.profile_no_reviews,
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                profile.rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontFamily: dsFontFamily,
                  fontSize: 30,
                  fontWeight: DSFontWeight.bold,
                  color: DSColor.onSurface,
                ),
              ),
              const SizedBox(width: 12),
              DSStarRating(
                rating: profile.rating,
                reviewCount: profile.reviewCount,
                starSize: 15,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...reviews.map((UserReview r) => ReviewCardWidget(review: r)),
        ],
      ),
    );
  }
}
