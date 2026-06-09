import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:klozy/src/design/tokens/ds_border_radius.dart';

/// [DSGlassButton] — bouton circulaire semi-transparent avec backdrop blur.
///
/// Utilisé en overlay sur les galeries d'images (retour, options, partage).
/// Le blur rend le bouton lisible sur n'importe quelle couleur de fond photo.
///
/// Ne pas utiliser sur des fonds uniformes — préférer [DSIconButton] dans ce cas.
///
/// Tokens :
/// - background : rgba(0,0,0,0.48)
/// - blur       : sigmaX=12, sigmaY=12
/// - border     : rgba(255,255,255,0.18) · 0.5 px
/// - radius     : [DSBorderRadius.heavy] (100)
/// - size       : [buttonSize] défaut 38
class DSGlassButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double buttonSize;

  const DSGlassButton({
    super.key,
    required this.child,
    this.onTap,
    this.buttonSize = 38,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DSBorderRadius.heavy),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.48),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.18),
                width: 0.5,
              ),
            ),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
