import 'package:flutter/material.dart';

import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';

/// [DSFilterChip] — chip de filtre catégorie avec état actif/inactif.
///
/// Étend [DSChip] en ajoutant la notion d'état sélectionné.
/// À utiliser dans une [SingleChildScrollView] horizontal pour
/// la barre de filtres du Home feed.
///
/// État actif  : fond [DSColor.primary] · texte [DSColor.surface] · semiBold
/// État inactif: fond [DSColor.onSurface07] · bordure [DSColor.onSurface15]
///               · texte [DSColor.onSurface75] · regular
///
/// Radius : [DSBorderRadius.chip] (pill = 999)
class DSFilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const DSFilterChip({
    super.key,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.s,
          vertical: DSSpacing.xxs - 1,
        ),
        decoration: BoxDecoration(
          color: isActive ? DSColor.primary : DSColor.onSurface07,
          borderRadius: BorderRadius.circular(DSBorderRadius.chip),
          border: Border.all(
            color: isActive ? Colors.transparent : DSColor.onSurface15,
            width: 0.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: dsFontFamily,
            fontSize: DSFontSize.bodySmall,
            fontWeight: isActive ? DSFontWeight.semiBold : DSFontWeight.regular,
            color: isActive ? DSColor.surface : DSColor.onSurface75,
          ),
        ),
      ),
    );
  }
}
