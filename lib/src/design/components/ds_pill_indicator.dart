import 'package:flutter/material.dart';

import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';

/// [DSPillIndicator] — indicateur de pagination pour carousels.
///
/// Remplace les dots classiques par des barres fines animées.
/// La barre active s'élargit à [activeWidth] (défaut 22) via AnimatedContainer.
/// Les barres inactives restent à [inactiveWidth] (défaut 6).
///
/// Utilisé sur :
/// - ProductDetailScreen — galerie d'images produit
/// - Tout futur carousel (Reels, onboarding, etc.)
///
/// Tokens :
/// - active   : [activeColor] (défaut [DSColor.primary])
/// - inactive : [DSColor.onSurface35]
/// - height   : 3 px fixe
/// - radius   : [DSBorderRadius.heavy] (100)
class DSPillIndicator extends StatelessWidget {
  final int count;
  final int activeIndex;
  final Color activeColor;
  final double activeWidth;
  final double inactiveWidth;
  final double gap;

  const DSPillIndicator({
    super.key,
    required this.count,
    required this.activeIndex,
    this.activeColor = DSColor.primary,
    this.activeWidth = 22,
    this.inactiveWidth = 6,
    this.gap = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final isActive = i == activeIndex;
        return Padding(
          padding: EdgeInsets.only(right: i < count - 1 ? gap : 0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOut,
            width: isActive ? activeWidth : inactiveWidth,
            height: 3,
            decoration: BoxDecoration(
              color: isActive ? activeColor : DSColor.onSurface35,
              borderRadius: BorderRadius.circular(DSBorderRadius.heavy),
            ),
          ),
        );
      }),
    );
  }
}
