import 'package:flutter/material.dart';

import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';

/// [DSStarRating] — affichage d'une note étoilée avec compteur d'avis.
///
/// Utilisé sur :
/// - ProductDetailScreen — note du vendeur
/// - SellerProfileScreen — note globale du vendeur
///
/// Arrondi au demi-point pour le remplissage des étoiles.
/// Pas de saisie interactive — readonly uniquement.
///
/// Tokens :
/// - star filled   : [DSColor.primary] (#E0CE7D)
/// - star empty    : [DSColor.onSurface15]
/// - count text    : [DSColor.onSurface45] · 11 px
/// - rating text   : [DSColor.onSurface45] · 11 px
/// - gap entre étoiles : 2 px
class DSStarRating extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final Color accentColor;
  final double starSize;
  final bool showCount;

  const DSStarRating({
    super.key,
    required this.rating,
    this.reviewCount = 0,
    this.accentColor = DSColor.primary,
    this.starSize = 11,
    this.showCount = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Stars
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (i) {
            final filled = i < rating.round();
            return Padding(
              padding: const EdgeInsets.only(right: 2),
              child: Icon(
                filled ? Icons.star_rounded : Icons.star_outline_rounded,
                size: starSize,
                color: filled ? accentColor : DSColor.onSurface15,
              ),
            );
          }),
        ),
        const SizedBox(width: 5),
        // Rating value + count
        if (showCount)
          Text(
            '$rating  ($reviewCount)',
            style: const TextStyle(
              fontFamily: dsFontFamily,
              fontSize: 11,
              color: DSColor.onSurface45,
              height: 1,
            ),
          ),
      ],
    );
  }
}
