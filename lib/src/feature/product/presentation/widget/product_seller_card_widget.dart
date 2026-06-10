import 'package:flutter/material.dart';
import 'package:klozy/src/design/components/ds_star_rating.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/domain/product/entity/product_detail.dart';
import 'package:klozy/src/feature/product/presentation/widget/product_heart_button_widget.dart';

class ProductSellerCardWidget extends StatelessWidget {
  final ProductSeller seller;
  final bool isOwner;
  final VoidCallback onMessage;
  final VoidCallback? onTap;
  final ProductDetail? detail;

  const ProductSellerCardWidget({
    super.key,
    required this.seller,
    required this.isOwner,
    required this.onMessage,
    this.onTap,
    this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: DSColor.onSurface07,
          borderRadius: BorderRadius.circular(DSBorderRadius.card),
          border: Border.all(color: DSColor.onSurface10, width: 0.5),
        ),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 22,
              backgroundColor: DSColor.lowBlack,
              backgroundImage: seller.avatarUrl == null
                  ? null
                  : NetworkImage(seller.avatarUrl!),
              child: seller.avatarUrl == null
                  ? const Icon(Icons.person, size: 22, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          seller.displayName.isEmpty
                              ? '@${seller.handle}'
                              : seller.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: dsFontFamily,
                            fontSize: 14.5,
                            fontWeight: DSFontWeight.semiBold,
                            color: DSColor.onSurface,
                          ),
                        ),
                      ),
                      if (seller.isPro) ...<Widget>[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0x1FE0CE7D),
                            borderRadius: BorderRadius.circular(
                              DSBorderRadius.chip,
                            ),
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
                  const SizedBox(height: 4),
                  DSStarRating(
                    rating: seller.rating,
                    reviewCount: seller.reviewCount,
                    starSize: 12,
                  ),
                ],
              ),
            ),
            if (!isOwner) ...<Widget>[
              if (detail != null) ...<Widget>[
                ProductHeartButtonWidget(detail: detail!),
                const SizedBox(width: 8),
              ],
              GestureDetector(
                onTap: onMessage,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: DSColor.onSurface07,
                    shape: BoxShape.circle,
                    border: Border.all(color: DSColor.onSurface15, width: 0.5),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 18,
                    color: DSColor.onSurface75,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
