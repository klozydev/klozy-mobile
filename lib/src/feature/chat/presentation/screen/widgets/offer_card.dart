import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_message.dart';
import 'package:klozy/src/feature/chat/domain/entity/offer_data.dart';

/// A negotiation offer card. Border colour reflects the offer state
/// (pending / accepted / refused). When the offer is pending and incoming,
/// Refuse / Accept actions are surfaced; otherwise a status line is shown.
class OfferCard extends StatelessWidget {
  const OfferCard({
    super.key,
    required this.message,
    this.onAccept,
    this.onRefuse,
  });

  final ChatMessage message;
  final VoidCallback? onAccept;
  final VoidCallback? onRefuse;

  static String _formatPrice(num n) =>
      n == n.roundToDouble() ? n.toInt().toString() : n.toString();

  @override
  Widget build(BuildContext context) {
    final OfferData? offer = message.offer;
    if (offer == null) return const SizedBox.shrink();

    final Color borderColor = offer.isAccepted
        ? DSColor.chatPositive.withValues(alpha: 0.45)
        : (offer.isRefused
              ? Colors.white.withValues(alpha: 0.10)
              : DSColor.primary);

    return Container(
      width: 248,
      decoration: BoxDecoration(
        color: DSColor.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[_header(context, offer), _body(context, offer)],
      ),
    );
  }

  Widget _header(BuildContext context, OfferData offer) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Color(0xFF181818), Color(0xFF2A2A2A)],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  offer.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: dsFontFamily,
                    fontSize: 13,
                    fontWeight: DSFontWeight.semiBold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_formatPrice(offer.listedPrice)} ${context.l10N.chat_currency}',
                  style: TextStyle(
                    fontFamily: dsFontFamily,
                    fontSize: 11,
                    fontWeight: DSFontWeight.medium,
                    decoration: TextDecoration.lineThrough,
                    color: Colors.white.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, OfferData offer) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            message.isMine
                ? context.l10N.chat_offer_yours
                : context.l10N.chat_offer_incoming,
            style: TextStyle(
              fontFamily: dsFontFamily,
              fontSize: 11,
              fontWeight: DSFontWeight.medium,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(height: 2),
          Text.rich(
            TextSpan(
              children: <InlineSpan>[
                TextSpan(
                  text: _formatPrice(offer.offerPrice),
                  style: const TextStyle(
                    fontFamily: dsFontFamily,
                    fontSize: 20,
                    fontWeight: DSFontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                TextSpan(
                  text: ' ${context.l10N.chat_currency}',
                  style: TextStyle(
                    fontFamily: dsFontFamily,
                    fontSize: 13,
                    fontWeight: DSFontWeight.medium,
                    color: Colors.white.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ),
          _statusOrActions(context, offer),
        ],
      ),
    );
  }

  Widget _statusOrActions(BuildContext context, OfferData offer) {
    if (offer.isPending && !message.isMine) {
      return Padding(
        padding: const EdgeInsets.only(top: 11),
        child: Row(
          children: <Widget>[
            Expanded(child: _refuseButton(context)),
            const SizedBox(width: 8),
            Expanded(child: _acceptButton(context)),
          ],
        ),
      );
    }
    if (offer.isPending && message.isMine) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          context.l10N.chat_offer_pending,
          style: const TextStyle(
            fontFamily: dsFontFamily,
            fontSize: 11,
            fontWeight: DSFontWeight.semiBold,
            color: DSColor.primary,
          ),
        ),
      );
    }
    if (offer.isAccepted) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          '✓ ${context.l10N.chat_offer_accepted}',
          style: const TextStyle(
            fontFamily: dsFontFamily,
            fontSize: 11,
            fontWeight: DSFontWeight.bold,
            color: DSColor.chatPositive,
          ),
        ),
      );
    }
    if (offer.isRefused) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          context.l10N.chat_offer_declined,
          style: TextStyle(
            fontFamily: dsFontFamily,
            fontSize: 11,
            fontWeight: DSFontWeight.semiBold,
            color: Colors.white.withValues(alpha: 0.45),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _refuseButton(BuildContext context) {
    return GestureDetector(
      onTap: onRefuse,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.24),
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          context.l10N.chat_offer_refuse,
          style: const TextStyle(
            fontFamily: dsFontFamily,
            fontSize: 13,
            fontWeight: DSFontWeight.semiBold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _acceptButton(BuildContext context) {
    return GestureDetector(
      onTap: onAccept,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: DSColor.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          context.l10N.chat_offer_accept,
          style: const TextStyle(
            fontFamily: dsFontFamily,
            fontSize: 13,
            fontWeight: DSFontWeight.semiBold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
