import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';

/// The Klozy wordmark: `KL` + a gold ring + `ZY`, scaled by [size]. Mirrors the
/// prototype `KlozyMark`.
class DSKlozyMark extends StatelessWidget {
  final double size;
  final Color color;
  final Color accent;

  const DSKlozyMark({
    super.key,
    this.size = 34,
    this.color = DSColor.onSurface,
    this.accent = DSColor.primary,
  });

  @override
  Widget build(BuildContext context) {
    final double ring = size * 0.62;
    final TextStyle letters = TextStyle(
      fontFamily: dsFontFamily,
      fontSize: size,
      fontWeight: FontWeight.w800,
      height: 1,
      letterSpacing: size * -0.04,
      color: color,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text('KL', style: letters),
        Container(
          margin: EdgeInsets.symmetric(horizontal: size * 0.02),
          width: ring,
          height: ring,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: accent, width: size * 0.13),
          ),
        ),
        Text('ZY', style: letters),
      ],
    );
  }
}
