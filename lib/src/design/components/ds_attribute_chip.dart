import 'package:flutter/material.dart';

import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';

/// [DSAttributeChip] — chip d'attribut produit, stateless (pas d'état actif).
///
/// Distinct de [DSFilterChip] : pas de sélection possible.
/// Affiche un attribut produit (taille, état, marque, catégorie).
/// À utiliser dans un Wrap horizontal sur la page produit.
///
/// Tokens :
/// - background : transparent
/// - border     : [DSColor.onSurface15] · 0.5 px
/// - radius     : [DSBorderRadius.light] (8)
/// - text       : [DSColor.onSurface65] · [DSFontSize.bodySmall] · regular
/// - padding    : h=[DSSpacing.xs], v=6
class DSAttributeChip extends StatelessWidget {
  final String label;

  const DSAttributeChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.xs,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(DSBorderRadius.light),
        border: Border.all(color: DSColor.onSurface15, width: 0.5),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: dsFontFamily,
          fontSize: DSFontSize.bodySmall,
          fontWeight: DSFontWeight.regular,
          color: DSColor.onSurface65,
          height: 1,
        ),
      ),
    );
  }
}
