import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/domain/cart/entity/cart_bucket.dart';
import 'package:klozy/src/domain/cart/entity/cart_bundle.dart';
import 'package:klozy/src/domain/cart/entity/cart_item.dart';

/// Bucket card matching the cart design: each item can carry its own offer, a
/// seller can have one or more bundle ("offer for all") offers, and items added
/// after an offer are flagged and excluded.
class CartBucketCardWidget extends StatelessWidget {
  static const Color _accent = DSColor.primary;
  static const Color _green = Color(0xFFA7D2BE);

  final CartBucket bucket;
  final ValueChanged<String> onRemoveItem;
  final ValueChanged<CartItem> onMakeItemOffer;
  final ValueChanged<String> onCancelOffer;
  final VoidCallback onMakeBundleOffer;
  final VoidCallback onCheckout;
  final VoidCallback? onMessageSeller;

  const CartBucketCardWidget({
    super.key,
    required this.bucket,
    required this.onRemoveItem,
    required this.onMakeItemOffer,
    required this.onCancelOffer,
    required this.onMakeBundleOffer,
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
          const SizedBox(height: 8),
          ...bucket.items.map((CartItem item) => _itemRow(context, item)),
          ...bucket.bundles.map((CartBundle b) => _bundleBanner(context, b)),
          if (bucket.canBundle) ...<Widget>[
            const SizedBox(height: 12),
            _bundleButton(context),
          ],
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
                context.l10N.cart_price_dhs(bucket.subtotal.round()),
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
          DSButtonElevated(
            text: context.l10N.cart_checkout_amount(bucket.subtotal.round()),
            onPressed: onCheckout,
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                          context.l10N.cart_price_dhs(
                            item.effectivePrice.round(),
                          ),
                          style: const TextStyle(
                            fontFamily: dsFontFamily,
                            fontSize: DSFontSize.bodyMedium,
                            fontWeight: DSFontWeight.bold,
                            color: DSColor.onSurface,
                          ),
                        ),
                        if (item.offerAccepted) ...<Widget>[
                          const SizedBox(width: 8),
                          Text(
                            context.l10N.cart_price_dhs(item.price.round()),
                            style: const TextStyle(
                              fontFamily: dsFontFamily,
                              fontSize: DSFontSize.bodySmall,
                              color: DSColor.onSurface35,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
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
          Padding(
            padding: const EdgeInsets.only(left: 68, top: 8),
            child: _offerControl(context, item),
          ),
        ],
      ),
    );
  }

  Widget _offerControl(BuildContext context, CartItem item) {
    if (item.inBundle) {
      final bool accepted = item.offerStatus == CartOfferStatus.accepted;
      return _tag(
        accepted
            ? context.l10N.cart_in_accepted_bundle
            : context.l10N.cart_in_bundle,
        accepted ? _green : _accent,
      );
    }
    final List<Widget> children = <Widget>[];
    if (item.addedAfter) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 7),
          child: Text(
            context.l10N.cart_added_after_bundle,
            style: const TextStyle(
              fontFamily: dsFontFamily,
              fontSize: DSFontSize.bodySmall,
              color: DSColor.onSurface35,
            ),
          ),
        ),
      );
    }
    if (item.offerPending) {
      children.add(
        Row(
          children: <Widget>[
            _tag(
              context.l10N.cart_offer_sent_amount(
                (item.offerAmount ?? 0).round(),
              ),
              _accent,
            ),
            const SizedBox(width: 10),
            _cancelButton(context, item.offerId!),
          ],
        ),
      );
    } else if (item.offerAccepted) {
      children.add(
        _tag(
          context.l10N.cart_offer_accepted_save(
            (item.price - (item.offerAmount ?? item.price)).round(),
          ),
          _green,
        ),
      );
    } else {
      children.add(_makeOfferPill(context, () => onMakeItemOffer(item)));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _bundleBanner(BuildContext context, CartBundle bundle) {
    final bool accepted = bundle.accepted;
    final Color color = accepted ? _green : _accent;
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(DSBorderRadius.light),
        border: Border.all(color: color.withValues(alpha: 0.28), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.sell_outlined, size: 15, color: color),
              const SizedBox(width: 8),
              Text(
                context.l10N.cart_bundle_title(bundle.itemCount),
                style: const TextStyle(
                  fontFamily: dsFontFamily,
                  fontSize: DSFontSize.bodyMedium,
                  fontWeight: DSFontWeight.semiBold,
                  color: DSColor.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                context.l10N.cart_price_dhs(bundle.amount.round()),
                style: TextStyle(
                  fontFamily: dsFontFamily,
                  fontSize: DSFontSize.bodyLarge,
                  fontWeight: DSFontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: <Widget>[
              _tag(
                accepted
                    ? context.l10N.cart_bundle_accepted
                    : context.l10N.cart_bundle_pending,
                color,
              ),
              const SizedBox(width: 10),
              Text(
                context.l10N.cart_bundle_was(bundle.listSum.round()),
                style: const TextStyle(
                  fontFamily: dsFontFamily,
                  fontSize: DSFontSize.bodySmall,
                  color: DSColor.onSurface45,
                ),
              ),
              const Spacer(),
              _cancelButton(context, bundle.id),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bundleButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: OutlinedButton.icon(
        onPressed: onMakeBundleOffer,
        icon: const Icon(Icons.sell_outlined, size: 14, color: _accent),
        label: Text(
          context.l10N.cart_offer_for_all(bucket.standaloneProductIds.length),
          style: const TextStyle(
            fontFamily: dsFontFamily,
            fontSize: DSFontSize.bodyMedium,
            fontWeight: DSFontWeight.semiBold,
            color: _accent,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: _accent.withValues(alpha: 0.4), width: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DSBorderRadius.input),
          ),
        ),
      ),
    );
  }

  Widget _makeOfferPill(BuildContext context, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 13),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _accent.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(DSBorderRadius.chip),
          border: Border.all(
            color: _accent.withValues(alpha: 0.30),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.sell_outlined, size: 13, color: _accent),
            const SizedBox(width: 6),
            Text(
              context.l10N.cart_make_an_offer,
              style: const TextStyle(
                fontFamily: dsFontFamily,
                fontSize: DSFontSize.bodyMedium,
                fontWeight: DSFontWeight.semiBold,
                color: _accent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cancelButton(BuildContext context, String offerId) {
    return GestureDetector(
      onTap: () => onCancelOffer(offerId),
      child: Text(
        context.l10N.cart_cancel,
        style: const TextStyle(
          fontFamily: dsFontFamily,
          fontSize: DSFontSize.bodyMedium,
          fontWeight: DSFontWeight.semiBold,
          color: DSColor.onSurface60,
        ),
      ),
    );
  }

  Widget _tag(String label, Color color) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(DSBorderRadius.chip),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: dsFontFamily,
          fontSize: DSFontSize.bodySmall,
          fontWeight: DSFontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
