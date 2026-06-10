import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_button_outline.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/domain/offers/entity/offer.dart';

class OfferRowWidget extends StatelessWidget {
  final Offer offer;
  final bool incoming;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onCancel;

  const OfferRowWidget({
    super.key,
    required this.offer,
    required this.incoming,
    required this.onAccept,
    required this.onDecline,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final bool pending = offer.status == OfferStatus.pending;
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
                radius: 18,
                backgroundColor: DSColor.lowBlack,
                backgroundImage: offer.counterpartAvatar == null
                    ? null
                    : NetworkImage(offer.counterpartAvatar!),
                child: offer.counterpartAvatar == null
                    ? const Icon(Icons.person, size: 18, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      offer.counterpartName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: dsFontFamily,
                        fontSize: DSFontSize.bodyLarge,
                        fontWeight: DSFontWeight.semiBold,
                        color: DSColor.onSurface,
                      ),
                    ),
                    Text(
                      context.l10N.cart_price_dhs(offer.amount.toInt()),
                      style: const TextStyle(
                        fontFamily: dsFontFamily,
                        fontSize: DSFontSize.bodyMedium,
                        fontWeight: DSFontWeight.bold,
                        color: DSColor.primary,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusPill(status: offer.status),
            ],
          ),
          if (pending) ...<Widget>[
            const SizedBox(height: 12),
            if (incoming)
              Row(
                children: <Widget>[
                  Expanded(
                    child: DSButtonOutline(
                      text: context.l10N.offers_decline,
                      onPressed: onDecline,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DSButtonElevated(
                      text: context.l10N.offers_accept,
                      onPressed: onAccept,
                    ),
                  ),
                ],
              )
            else
              DSButtonOutline(
                text: context.l10N.cart_cancel_offer,
                onPressed: onCancel,
              ),
          ],
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final OfferStatus status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final (String label, Color color) = switch (status) {
      OfferStatus.pending => (
        context.l10N.offers_status_pending,
        DSColor.primary,
      ),
      OfferStatus.accepted => (
        context.l10N.offers_status_accepted,
        const Color(0xFFA7D2BE),
      ),
      OfferStatus.declined => (
        context.l10N.offers_status_declined,
        DSColor.onSurface45,
      ),
      OfferStatus.cancelled => (
        context.l10N.offers_status_cancelled,
        DSColor.onSurface45,
      ),
      OfferStatus.unknown => ('—', DSColor.onSurface45),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(DSBorderRadius.chip),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontFamily: dsFontFamily,
          fontSize: 9,
          fontWeight: DSFontWeight.bold,
          letterSpacing: 0.4,
          color: color,
        ),
      ),
    );
  }
}
