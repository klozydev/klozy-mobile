import 'package:flutter/material.dart';

/// Paints the faint repeating diagonal hairlines of the prototype `Placeholder`
/// (`repeating-linear-gradient(135deg, …)`): a 1px line every [spacing] px.
class DiagonalStripesPainter extends CustomPainter {
  final Color color;
  final double spacing;

  const DiagonalStripesPainter({required this.color, this.spacing = 9});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // 135deg lines: slope of -1, swept from top-left past bottom-right.
    final double extent = size.width + size.height;
    for (double x = 0; x <= extent; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x - size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(DiagonalStripesPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.spacing != spacing;
}
