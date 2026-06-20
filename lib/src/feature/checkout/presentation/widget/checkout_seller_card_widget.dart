import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/domain/cart/entity/cart_bucket.dart';
import 'package:klozy/src/domain/cart/entity/cart_item.dart';

/// Checkout seller card — avatar, name, PRO badge, item count, a chat shortcut,
/// the per-item list, and a "Buy more from {seller}" link to their profile.
class CheckoutSellerCardWidget extends StatelessWidget {
  final CartBucket bucket;
  final VoidCallback onOpenSeller;
  final VoidCallback onMessage;

  const CheckoutSellerCardWidget({
    super.key,
    required this.bucket,
    required this.onOpenSeller,
    required this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              Expanded(
                child: GestureDetector(
                  onTap: onOpenSeller,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: DSColor.lowBlack,
                        backgroundImage: bucket.sellerAvatar == null
                            ? null
                            : NetworkImage(bucket.sellerAvatar!),
                        child: bucket.sellerAvatar == null
                            ? const Icon(
                                Icons.person,
                                size: 20,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Flexible(
                                  child: Text(
                                    bucket.sellerName,
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
                                if (bucket.isPro) ...<Widget>[
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
                                    child: Text(
                                      context.l10N.cart_pro_badge,
                                      style: const TextStyle(
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
                            const SizedBox(height: 1),
                            Text(
                              context.l10N.cart_item_count(bucket.items.length),
                              style: const TextStyle(
                                fontFamily: dsFontFamily,
                                fontSize: DSFontSize.bodySmall,
                                color: DSColor.onSurface45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onMessage,
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: DSColor.onSurface07,
                    border: Border.all(color: DSColor.onSurface12, width: 0.5),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 18,
                    color: DSColor.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final CartItem item in bucket.items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(DSBorderRadius.image),
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: item.image == null
                          ? const ColoredBox(color: DSColor.lowBlack)
                          : CachedNetworkImage(
                              imageUrl: item.image!,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: dsFontFamily,
                            fontSize: DSFontSize.bodyLarge,
                            fontWeight: DSFontWeight.semiBold,
                            color: DSColor.onSurface,
                          ),
                        ),
                        if (item.meta.isNotEmpty)
                          Text(
                            item.meta,
                            style: const TextStyle(
                              fontFamily: dsFontFamily,
                              fontSize: DSFontSize.bodySmall,
                              color: DSColor.onSurface45,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.l10N.cart_price_dhs(item.effectivePrice.round()),
                    style: const TextStyle(
                      fontFamily: dsFontFamily,
                      fontSize: DSFontSize.bodyLarge,
                      fontWeight: DSFontWeight.bold,
                      color: DSColor.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: onOpenSeller,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    context.l10N.checkout_buy_more_from(
                      bucket.sellerName.split(' ').first,
                    ),
                    style: const TextStyle(
                      fontFamily: dsFontFamily,
                      fontSize: DSFontSize.bodySmall,
                      fontWeight: DSFontWeight.medium,
                      color: DSColor.onSurface45,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: DSColor.onSurface45,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
