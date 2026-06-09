import 'package:flutter/material.dart';
import 'package:klozy/src/design/components/ds_star_rating.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/domain/social/entity/user_review.dart';

class ReviewCardWidget extends StatelessWidget {
  final UserReview review;

  const ReviewCardWidget({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DSColor.card,
        borderRadius: BorderRadius.circular(DSBorderRadius.card),
        border: Border.all(color: DSColor.onSurface07, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                radius: 16,
                backgroundColor: DSColor.lowBlack,
                backgroundImage: review.authorAvatar == null
                    ? null
                    : NetworkImage(review.authorAvatar!),
                child: review.authorAvatar == null
                    ? const Icon(Icons.person, size: 16, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  review.authorName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: dsFontFamily,
                    fontSize: DSFontSize.bodyMedium,
                    fontWeight: DSFontWeight.semiBold,
                    color: DSColor.onSurface,
                  ),
                ),
              ),
              DSStarRating(
                rating: review.rating,
                showCount: false,
                starSize: 11,
              ),
            ],
          ),
          if (review.body.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              review.body,
              style: const TextStyle(
                fontFamily: dsFontFamily,
                fontSize: DSFontSize.bodyMedium,
                height: 1.4,
                color: DSColor.onSurface75,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
