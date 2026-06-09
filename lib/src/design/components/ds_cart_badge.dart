import 'package:flutter/material.dart';

import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';

/// [DSCartBadge] — icône panier avec badge numérique.
///
/// Placé en top-right de la top bar ; remplace l'avatar profil.
/// Le badge gold [DSColor.primary] est masqué si [count] == 0.
/// Affiche "9+" pour [count] > 9.
///
/// Justification UX : right-anchored transactional shortcut,
/// convention universelle e-commerce (logo gauche / panier droit).
/// Le profil reste accessible en permanence via la bottom nav.
///
/// Tokens :
/// - badge bg   : [DSColor.primary]
/// - badge text : [DSColor.surface] · 9 px · bold
/// - badge border: [DSColor.surface] · 1.5 px (séparation visuelle)
/// - radius badge: [DSBorderRadius.heavy] (100)
class DSCartBadge extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;

  const DSCartBadge({super.key, required this.count, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 36,
        height: 36,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Center(
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 22,
                color: DSColor.onSurface,
              ),
            ),
            if (count > 0)
              Positioned(
                top: 1,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  decoration: BoxDecoration(
                    color: DSColor.primary,
                    borderRadius: BorderRadius.circular(DSBorderRadius.heavy),
                    border: Border.all(color: DSColor.surface, width: 1.5),
                  ),
                  child: Text(
                    count > 9 ? '9+' : '$count',
                    style: const TextStyle(
                      fontFamily: dsFontFamily,
                      fontSize: 9,
                      fontWeight: DSFontWeight.bold,
                      color: DSColor.surface,
                      height: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
