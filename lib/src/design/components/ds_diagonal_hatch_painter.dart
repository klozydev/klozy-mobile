import 'package:flutter/material.dart';

/// Faint repeating diagonal hairlines (the prototype `Placeholder` hatch:
/// `repeating-linear-gradient(135deg, …)`) — a 1px line every [spacing] px.
class DSDiagonalHatchPainter extends CustomPainter {
  final Color color;
  final double spacing;

  const DSDiagonalHatchPainter({required this.color, this.spacing = 9});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

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
  bool shouldRepaint(DSDiagonalHatchPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.spacing != spacing;
}
