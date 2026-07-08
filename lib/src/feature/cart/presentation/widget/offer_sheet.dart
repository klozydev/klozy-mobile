import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_network_image/ds_network_image.dart';
import 'package:klozy/src/design/components/ds_network_image/ds_network_image_shape.dart';
import 'package:klozy/src/design/components/ds_text_field.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/domain/cart/entity/cart_item.dart';

/// "Make an offer" body — one offer for the whole seller bucket. Shows the
/// seller header and a per-item list (design: the offer covers everything from
/// this seller), then the amount field. Returns the amount via `Navigator.pop`.
class OfferSheet extends StatefulWidget {
  final num subtotal;
  final String sellerName;
  final String? sellerAvatar;
  final bool isPro;
  final List<CartItem> items;

  const OfferSheet({
    super.key,
    required this.subtotal,
    required this.sellerName,
    required this.items,
    this.sellerAvatar,
    this.isPro = false,
  });

  int get itemCount => items.length;

  @override
  State<OfferSheet> createState() => _OfferSheetState();
}

class _OfferSheetState extends State<OfferSheet> {
  final TextEditingController _amount = TextEditingController();

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  num? get _value => num.tryParse(_amount.text.trim());
  bool get _valid => _value != null && _value! > 0 && _value! < widget.subtotal;

  void _preset(double pct) {
    setState(() => _amount.text = (widget.subtotal * pct).round().toString());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Seller header — avatar, name, PRO badge, and "N items · listed at X".
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: <Widget>[
              DSNetworkImage(
                imageUrl: widget.sellerAvatar,
                width: 34,
                height: 34,
                shape: DSNetworkImageShape.circle,
                fallback: const CircleAvatar(
                  radius: 17,
                  backgroundColor: DSColor.lowBlack,
                  child: Icon(Icons.person, size: 17, color: Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            widget.sellerName,
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
                        if (widget.isPro) ...<Widget>[
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
                      context.l10N.cart_offer_seller_meta(
                        widget.items.length,
                        widget.subtotal,
                      ),
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
        // Per-item list — small thumbnail, title, listed price.
        for (final CartItem item in widget.items)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: <Widget>[
                DSNetworkImage(
                  imageUrl: item.image,
                  width: 32,
                  height: 32,
                  borderRadius: DSBorderRadius.light,
                  fallback: const ColoredBox(color: DSColor.lowBlack),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: dsFontFamily,
                      fontSize: DSFontSize.bodyMedium,
                      color: DSColor.onSurface75,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10N.cart_price_dhs(item.price.round()),
                  style: const TextStyle(
                    fontFamily: dsFontFamily,
                    fontSize: DSFontSize.bodyMedium,
                    color: DSColor.onSurface45,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        DSTextField(
          controller: _amount,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
          ],
          hintText: widget.itemCount > 1
              ? context.l10N.cart_offer_hint_multi(widget.itemCount)
              : context.l10N.cart_offer_hint_single,
          onChanged: (_) => setState(() {}),
          trailing: Text(
            context.l10N.cart_currency_dhs,
            style: const TextStyle(
              fontFamily: dsFontFamily,
              fontSize: DSFontSize.bodyLarge,
              fontWeight: DSFontWeight.semiBold,
              color: DSColor.onSurface45,
            ),
          ),
          errorText: _amount.text.isNotEmpty && !_valid
              ? context.l10N.cart_offer_error_below_total
              : null,
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            _presetChip('70%', 0.7),
            const SizedBox(width: 8),
            _presetChip('80%', 0.8),
            const SizedBox(width: 8),
            _presetChip('90%', 0.9),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          context.l10N.cart_offer_chat_note,
          style: const TextStyle(
            fontFamily: dsFontFamily,
            fontSize: DSFontSize.bodySmall,
            height: 1.45,
            color: DSColor.onSurface35,
          ),
        ),
        const SizedBox(height: 12),
        // Escrow reassurance — funds are held until the buyer confirms delivery
        // (design: lock icon + note above the send button).
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(top: 1),
              child: Icon(
                Icons.lock_outline_rounded,
                size: 15,
                color: DSColor.onSurface45,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                context.l10N.cart_offer_escrow_note,
                style: const TextStyle(
                  fontFamily: dsFontFamily,
                  fontSize: DSFontSize.bodySmall,
                  height: 1.45,
                  color: DSColor.onSurface60,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        DSButtonElevated(
          text: context.l10N.cart_offer_send,
          isEnable: _valid,
          onPressed: () => Navigator.of(context).pop(_value),
        ),
      ],
    );
  }

  Widget _presetChip(String label, double pct) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _preset(pct),
        child: Container(
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: DSColor.onSurface07,
            borderRadius: BorderRadius.circular(DSBorderRadius.chip),
            border: Border.all(color: DSColor.onSurface15, width: 0.5),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: dsFontFamily,
              fontSize: DSFontSize.bodyMedium,
              fontWeight: DSFontWeight.medium,
              color: DSColor.onSurface75,
            ),
          ),
        ),
      ),
    );
  }
}
