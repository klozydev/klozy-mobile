import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_star_rating.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';

/// Header rating line: stars + value + (count), or "No reviews yet".
///
/// Matches the design: 15px stars, value in 13px semi-bold onSurface,
/// count in 13px 45% white. With no reviews shows the empty label in 35% white.
class ProfileRatingSummary extends StatelessWidget {
  final double rating;
  final int reviewCount;

  const ProfileRatingSummary({
    super.key,
    required this.rating,
    required this.reviewCount,
  });

  @override
  Widget build(BuildContext context) {
    if (reviewCount <= 0) {
      return Text(
        context.l10N.profile_no_reviews,
        style: const TextStyle(
          fontFamily: dsFontFamily,
          fontSize: DSFontSize.bodyMedium,
          color: DSColor.onSurface35,
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        DSStarRating(rating: rating, starSize: 15, showCount: false),
        const SizedBox(width: 7),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontFamily: dsFontFamily,
            fontSize: DSFontSize.bodyMedium,
            fontWeight: DSFontWeight.semiBold,
            color: DSColor.onSurface,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '($reviewCount)',
          style: const TextStyle(
            fontFamily: dsFontFamily,
            fontSize: DSFontSize.bodyMedium,
            color: DSColor.onSurface45,
          ),
        ),
      ],
    );
  }
}
