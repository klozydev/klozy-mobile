import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_button_outline.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/domain/cart/entity/cart_bucket.dart';
import 'package:klozy/src/domain/cart/entity/cart_item.dart';

class CartBucketCardWidget extends StatelessWidget {
  final CartBucket bucket;
  final ValueChanged<String> onRemoveItem;
  final VoidCallback onMakeOffer;
  final VoidCallback onCancelOffer;
  final VoidCallback onCheckout;
  final VoidCallback? onMessageSeller;

  const CartBucketCardWidget({
    super.key,
    required this.bucket,
    required this.onRemoveItem,
    required this.onMakeOffer,
    required this.onCancelOffer,
    required this.onCheckout,
    this.onMessageSeller,
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
          _sellerHead(context),
          const SizedBox(height: 12),
          ...bucket.items.map((CartItem item) => _itemRow(context, item)),
          const Divider(height: 24, color: DSColor.onSurface08),
          Row(
            children: <Widget>[
              Text(
                context.l10N.cart_subtotal,
                style: const TextStyle(
                  fontFamily: dsFontFamily,
                  fontSize: DSFontSize.bodyMedium,
                  color: DSColor.onSurface60,
                ),
              ),
              const Spacer(),
              Text(
                context.l10N.cart_price_dhs(bucket.subtotal.toInt()),
                style: const TextStyle(
                  fontFamily: dsFontFamily,
                  fontSize: DSFontSize.bodyLarge,
                  fontWeight: DSFontWeight.bold,
                  color: DSColor.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: bucket.hasPendingOffer
                    ? DSButtonOutline(
                        text: context.l10N.cart_cancel_offer,
                        onPressed: onCancelOffer,
                      )
                    : DSButtonOutline(
                        text: context.l10N.cart_make_an_offer,
                        onPressed: onMakeOffer,
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DSButtonElevated(
                  text: context.l10N.cart_check_out,
                  onPressed: onCheckout,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sellerHead(BuildContext context) {
    return Row(
      children: <Widget>[
        CircleAvatar(
          radius: 16,
          backgroundColor: DSColor.lowBlack,
          backgroundImage: bucket.sellerAvatar == null
              ? null
              : NetworkImage(bucket.sellerAvatar!),
          child: bucket.sellerAvatar == null
              ? const Icon(Icons.person, size: 16, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 10),
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
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0x1FE0CE7D),
              borderRadius: BorderRadius.circular(DSBorderRadius.chip),
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
        const Spacer(),
        Text(
          context.l10N.cart_item_count(bucket.items.length),
          style: const TextStyle(
            fontFamily: dsFontFamily,
            fontSize: DSFontSize.bodySmall,
            color: DSColor.onSurface45,
          ),
        ),
        if (onMessageSeller != null) ...<Widget>[
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onMessageSeller,
            child: const Padding(
              padding: EdgeInsets.all(2),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 18,
                color: DSColor.onSurface60,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _itemRow(BuildContext context, CartItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(DSBorderRadius.light),
            child: SizedBox(
              width: 56,
              height: 56,
              child: item.image == null
                  ? const ColoredBox(color: DSColor.lowBlack)
                  : Image.network(item.image!, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: dsFontFamily,
                    fontSize: DSFontSize.bodyMedium,
                    fontWeight: DSFontWeight.medium,
                    color: DSColor.onSurface,
                  ),
                ),
                Text(
                  item.meta,
                  style: const TextStyle(
                    fontFamily: dsFontFamily,
                    fontSize: DSFontSize.bodySmall,
                    color: DSColor.onSurface45,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: <Widget>[
                    Text(
                      context.l10N.cart_price_dhs(item.effectivePrice.toInt()),
                      style: const TextStyle(
                        fontFamily: dsFontFamily,
                        fontSize: DSFontSize.bodyMedium,
                        fontWeight: DSFontWeight.bold,
                        color: DSColor.onSurface,
                      ),
                    ),
                    if (item.offerStatus == CartOfferStatus.pending)
                      _badge(context.l10N.cart_offer_pending, DSColor.primary),
                    if (item.offerStatus == CartOfferStatus.accepted)
                      _badge(
                        context.l10N.cart_offer_accepted,
                        const Color(0xFFA7D2BE),
                      ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => onRemoveItem(item.productId),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.delete_outline_rounded,
                size: 20,
                color: DSColor.onSurface45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(DSBorderRadius.chip),
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            fontFamily: dsFontFamily,
            fontSize: 10,
            fontWeight: DSFontWeight.bold,
            letterSpacing: 0.4,
            color: color,
          ),
        ),
      ),
    );
  }
}
