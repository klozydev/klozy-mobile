import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';

/// Fills the letterbox around a contained product photo with the photo's own
/// edge colors, so the photo bleeds into the background instead of ending on a
/// hard rectangle against a mismatched blur.
///
/// The photo is laid out at [imageRatio] and centered, so exactly one axis is
/// barred: top/bottom when the photo is limited by width, left/right when
/// limited by height. This paints a gradient along that axis whose color at the
/// photo boundary matches the adjacent edge ([topColor]/[bottomColor] or
/// [leftColor]/[rightColor]), then darkens slightly toward the frame edge for a
/// soft vignette. The colors are sampled once from a tiny decode by
/// [ProductCarouselPhotoWidget]; when the photo already fills the frame there is
/// no bar to paint.
class ProductCarouselBackdropWidget extends StatelessWidget {
  /// How far the band darkens between the photo boundary and the frame edge.
  static const double _edgeDarken = 0.10;

  /// Below this bar fraction the photo effectively fills the frame; skip bands.
  static const double _minBarFraction = 0.02;

  final double imageRatio;
  final Color topColor;
  final Color bottomColor;
  final Color leftColor;
  final Color rightColor;

  const ProductCarouselBackdropWidget({
    super.key,
    required this.imageRatio,
    required this.topColor,
    required this.bottomColor,
    required this.leftColor,
    required this.rightColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double w = constraints.maxWidth;
        final double h = constraints.maxHeight;
        if (!w.isFinite || !h.isFinite || w <= 0 || h <= 0) {
          return const ColoredBox(color: DSColor.surface);
        }

        // Which axis is letterboxed follows from how the centered [AspectRatio]
        // fits: a photo wider (relative to the frame) than the frame is limited
        // by width and leaves top/bottom bars, and vice-versa.
        final bool topBottom = imageRatio >= w / h;
        final double photoExtent = topBottom ? w / imageRatio : h * imageRatio;
        final double frameExtent = topBottom ? h : w;
        final double bar = ((frameExtent - photoExtent) / 2 / frameExtent)
            .clamp(0.0, 0.5);
        if (bar < _minBarFraction) {
          return const ColoredBox(color: DSColor.surface);
        }

        final Color near0 = topBottom ? topColor : leftColor;
        final Color near1 = topBottom ? bottomColor : rightColor;
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: topBottom ? Alignment.topCenter : Alignment.centerLeft,
              end: topBottom ? Alignment.bottomCenter : Alignment.centerRight,
              stops: <double>[0, bar, 1 - bar, 1],
              colors: <Color>[_darken(near0), near0, near1, _darken(near1)],
            ),
          ),
        );
      },
    );
  }

  Color _darken(Color color) => Color.lerp(color, Colors.black, _edgeDarken)!;
}
