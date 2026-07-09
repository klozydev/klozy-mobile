import 'package:flutter/material.dart';

/// Softly dissolves the two edges of [child] along [axis] so a sharp-edged image
/// melts into whatever sits behind it instead of showing a hard line.
///
/// Works by masking [child]'s alpha with a [BlendMode.dstIn] [ShaderMask]: the
/// centre stays fully opaque and the alpha ramps to zero over a [feather]-wide
/// band at each end of [axis]. Only the letterboxed axis is faded — the other
/// axis bleeds to the frame edge, so there is no seam there to hide. The mask is
/// static, so the cost is a single extra layer.
///
/// [child] must fill the box it is handed ([BoxFit.cover] inside a matching
/// [AspectRatio]), otherwise the fade tracks the widget edge rather than the
/// image edge and drifts out of alignment.
class EdgeFeatherWidget extends StatelessWidget {
  /// Fraction (0..0.5) of each end consumed by the fade. Kept small so the
  /// dissolve stays subtle while still hiding the seam against the backdrop.
  static const double defaultFeather = 0.08;

  final Widget child;

  /// Axis whose two ends are feathered — [Axis.vertical] fades top and bottom,
  /// [Axis.horizontal] fades left and right.
  final Axis axis;
  final double feather;

  const EdgeFeatherWidget({
    super.key,
    required this.child,
    this.axis = Axis.vertical,
    this.feather = defaultFeather,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: _mask,
      child: child,
    );
  }

  // dstIn reads only the shader's alpha, so the opaque stops keep the child and
  // the transparent ends erase it; the RGB channels are irrelevant.
  Shader _mask(Rect bounds) {
    final bool horizontal = axis == Axis.horizontal;
    return LinearGradient(
      begin: horizontal ? Alignment.centerLeft : Alignment.topCenter,
      end: horizontal ? Alignment.centerRight : Alignment.bottomCenter,
      stops: <double>[0, feather, 1 - feather, 1],
      colors: const <Color>[
        Color(0x00FFFFFF),
        Color(0xFFFFFFFF),
        Color(0xFFFFFFFF),
        Color(0x00FFFFFF),
      ],
    ).createShader(bounds);
  }
}
