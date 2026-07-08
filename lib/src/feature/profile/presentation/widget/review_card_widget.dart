import 'package:flutter/material.dart';
import 'package:klozy/src/design/components/ds_network_image/ds_network_image.dart';
import 'package:klozy/src/design/components/ds_network_image/ds_network_image_shape.dart';
import 'package:klozy/src/design/components/ds_star_rating.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/domain/social/entity/user_review.dart';
import 'package:timeago/timeago.dart' as timeago;

class ReviewCardWidget extends StatelessWidget {
  final UserReview review;

  const ReviewCardWidget({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: DSColor.onSurface07, width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          DSNetworkImage(
            imageUrl: review.authorAvatar,
            width: 38,
            height: 38,
            shape: DSNetworkImageShape.circle,
            fallback: Container(
              width: 38,
              height: 38,
              color: DSColor.lowBlack,
              alignment: Alignment.center,
              child: const Icon(Icons.person, size: 19, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        review.authorName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: dsFontFamily,
                          fontSize: DSFontSize.bodyLarge,
                          fontWeight: DSFontWeight.semiBold,
                          color: DSColor.onSurface,
                        ),
                      ),
                    ),
                    if (review.createdAt != null)
                      Text(
                        timeago.format(review.createdAt!, locale: 'en_short'),
                        style: const TextStyle(
                          fontFamily: dsFontFamily,
                          fontSize: DSFontSize.bodySmall,
                          color: DSColor.onSurface35,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                DSStarRating(
                  rating: review.rating,
                  showCount: false,
                  starSize: 13,
                ),
                if (review.body.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 6),
                  Text(
                    review.body,
                    style: const TextStyle(
                      fontFamily: dsFontFamily,
                      fontSize: DSFontSize.bodyMedium,
                      height: 18 / DSFontSize.bodyMedium,
                      color: DSColor.onSurface65,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
