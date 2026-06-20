import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_set_composition_piece_row.dart';
import 'package:klozy/src/design/components/ds_set_composition_view.dart';
import 'package:klozy/src/design/components/ds_set_piece.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';

/// Spells out the pieces of a multi-item lot so a buyer knows exactly what's
/// included — even when the seller only photographed one piece. Ports the
/// reference `DSSetComposition`; use on the product detail when the listing is
/// a set.
class DSSetComposition extends StatelessWidget {
  final List<DSSetPiece> items;
  final DSSetCompositionView view;
  final Color accentColor;
  final VoidCallback? onAddPhoto;

  const DSSetComposition({
    super.key,
    required this.items,
    this.view = DSSetCompositionView.buyer,
    this.accentColor = DSColor.primary,
    this.onAddPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 7),
      decoration: BoxDecoration(
        color: DSColor.card,
        borderRadius: BorderRadius.circular(DSBorderRadius.normal),
        border: Border.all(color: DSColor.onSurface07, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.layers_outlined, size: 15, color: accentColor),
              const SizedBox(width: DSSpacing.xxs),
              Text(
                context.l10N.ds_set_composition_header,
                style: const TextStyle(
                  fontFamily: dsFontFamily,
                  fontSize: DSFontSize.bodyMedium,
                  fontWeight: DSFontWeight.semiBold,
                  color: DSColor.onSurface,
                ),
              ),
              const SizedBox(width: DSSpacing.xxs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DSSpacing.xxs,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(DSBorderRadius.chip),
                ),
                child: Text(
                  '${items.length}',
                  style: TextStyle(
                    fontFamily: dsFontFamily,
                    fontSize: 11,
                    fontWeight: DSFontWeight.semiBold,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.xs),
          for (int i = 0; i < items.length; i++)
            DSSetCompositionPieceRow(
              piece: items[i],
              view: view,
              accentColor: accentColor,
              showDivider: i > 0,
              onAddPhoto: onAddPhoto,
            ),
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 8),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: DSColor.onSurface07, width: 0.5),
              ),
            ),
            child: Text(
              view == DSSetCompositionView.owner
                  ? context.l10N.ds_set_composition_owner_note
                  : context.l10N.ds_set_composition_buyer_note,
              style: TextStyle(
                fontFamily: dsFontFamily,
                fontSize: 11.5,
                height: 1.45,
                color: view == DSSetCompositionView.owner
                    ? accentColor
                    : DSColor.onSurface35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
