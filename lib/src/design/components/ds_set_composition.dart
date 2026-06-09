import 'package:flutter/material.dart';

import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';

/// Une pièce d'un lot multi-articles (ex: maillot + short d'un ensemble).
class SetPiece {
  final String name;
  final String subLabel;
  final ImageProvider? photo; // null = pièce non photographiée

  const SetPiece({required this.name, required this.subLabel, this.photo});
}

/// Contexte d'affichage de la [DSSetComposition].
enum SetCompositionView { buyer, owner }

/// [DSSetComposition] — détaille explicitement les pièces d'un lot.
///
/// PROBLÈME RÉSOLU : quand un vendeur liste un "ensemble" (ex: maillot + short
/// de foot) mais ne photographie qu'une pièce, l'acheteur ne sait pas ce qu'il
/// achète. Ce composant énumère chaque pièce avec son statut photo.
///
/// Comportement :
/// - Pièce avec photo  → thumbnail + tag "Photo" ✓
/// - Pièce sans photo (buyer) → placeholder dashed + "Aucune photo" (honnête)
/// - Pièce sans photo (owner) → placeholder + bouton "Ajouter" (incitation)
///
/// À utiliser sur ProductDetailScreen quand product.isSet == true.
///
/// Tokens :
/// - container bg   : [DSColor.card]
/// - container radius: [DSBorderRadius.normal] (16)
/// - thumbnail radius: [DSBorderRadius.image] (12) → ici 10 arrondi
/// - accent (count, check, CTA): [accentColor] défaut [DSColor.primary]
class DSSetComposition extends StatelessWidget {
  final List<SetPiece> items;
  final SetCompositionView view;
  final Color accentColor;
  final VoidCallback? onAddPhoto;

  const DSSetComposition({
    super.key,
    required this.items,
    this.view = SetCompositionView.buyer,
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
        children: [
          // ── Header ──
          Row(
            children: [
              Icon(Icons.layers_outlined, size: 15, color: accentColor),
              const SizedBox(width: DSSpacing.xxs),
              const Text(
                'Cet ensemble contient',
                style: TextStyle(
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
                  color: accentColor.withOpacity(0.13),
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

          // ── Item rows ──
          for (var i = 0; i < items.length; i++)
            _PieceRow(
              piece: items[i],
              view: view,
              accentColor: accentColor,
              showDivider: i > 0,
              onAddPhoto: onAddPhoto,
            ),

          // ── Footnote ──
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 8),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: DSColor.onSurface07, width: 0.5),
              ),
            ),
            child: Text(
              view == SetCompositionView.owner
                  ? 'Ajoute une photo du short pour rassurer les acheteurs et vendre plus vite.'
                  : 'Le short est inclus mais n\u2019a pas été photographié. Contacte le vendeur pour plus de détails.',
              style: TextStyle(
                fontFamily: dsFontFamily,
                fontSize: 11.5,
                height: 1.45,
                color: view == SetCompositionView.owner
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

// ── _PieceRow ───────────────────────────────────────────────────────────────

class _PieceRow extends StatelessWidget {
  final SetPiece piece;
  final SetCompositionView view;
  final Color accentColor;
  final bool showDivider;
  final VoidCallback? onAddPhoto;

  const _PieceRow({
    required this.piece,
    required this.view,
    required this.accentColor,
    required this.showDivider,
    this.onAddPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: DSSpacing.xxs),
      decoration: showDivider
          ? const BoxDecoration(
              border: Border(
                top: BorderSide(color: DSColor.onSurface07, width: 0.5),
              ),
            )
          : null,
      child: Row(
        children: [
          _thumbnail(),
          const SizedBox(width: DSSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  piece.name,
                  style: const TextStyle(
                    fontFamily: dsFontFamily,
                    fontSize: 13.5,
                    fontWeight: DSFontWeight.medium,
                    color: DSColor.onSurface85,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  piece.subLabel,
                  style: const TextStyle(
                    fontFamily: dsFontFamily,
                    fontSize: 11.5,
                    color: DSColor.onSurface35,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: DSSpacing.xxs),
          _statusTag(),
        ],
      ),
    );
  }

  Widget _thumbnail() {
    if (piece.photo != null) {
      return Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: DSColor.onSurface10, width: 0.5),
          image: DecorationImage(image: piece.photo!, fit: BoxFit.cover),
        ),
      );
    }
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: DSColor.onSurface07,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: DSColor.onSurface15,
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
      child: Icon(
        view == SetCompositionView.owner
            ? Icons.add_rounded
            : Icons.image_not_supported_outlined,
        size: 16,
        color: DSColor.onSurface35,
      ),
    );
  }

  Widget _statusTag() {
    if (piece.photo != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_rounded, size: 13, color: accentColor),
          const SizedBox(width: 4),
          const Text(
            'Photo',
            style: TextStyle(
              fontFamily: dsFontFamily,
              fontSize: 11,
              color: DSColor.onSurface45,
            ),
          ),
        ],
      );
    }
    if (view == SetCompositionView.owner) {
      return GestureDetector(
        onTap: onAddPhoto,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(DSBorderRadius.chip),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.camera_alt_outlined, size: 12, color: DSColor.surface),
              SizedBox(width: 5),
              Text(
                'Ajouter',
                style: TextStyle(
                  fontFamily: dsFontFamily,
                  fontSize: 11,
                  fontWeight: DSFontWeight.semiBold,
                  color: DSColor.surface,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return const Text(
      'Aucune photo',
      style: TextStyle(
        fontFamily: dsFontFamily,
        fontSize: 11,
        color: DSColor.onSurface24,
      ),
    );
  }
}
