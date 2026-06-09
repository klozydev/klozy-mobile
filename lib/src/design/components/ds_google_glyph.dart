import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A compact 4-color Google "G" mark for the social sign-in button, painted so
/// no brand asset is needed. (Swap for the official asset if exact fidelity is
/// required.)
class DSGoogleGlyph extends StatelessWidget {
  final double size;

  const DSGoogleGlyph({super.key, this.size = 19});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _GoogleGPainter());
  }
}

class _GoogleGPainter extends CustomPainter {
  static const Color _blue = Color(0xFF4285F4);
  static const Color _red = Color(0xFFEA4335);
  static const Color _yellow = Color(0xFFFBBC05);
  static const Color _green = Color(0xFF34A853);

  double _deg(double d) => d * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.22;
    final radius = (size.width - stroke) / 2;
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: radius,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    void arc(Color color, double startDeg, double sweepDeg) {
      paint.color = color;
      canvas.drawArc(rect, _deg(startDeg), _deg(sweepDeg), false, paint);
    }

    arc(_red, -135, 90); // top
    arc(_blue, -45, 80); // right (+bar)
    arc(_green, 45, 90); // bottom
    arc(_yellow, 135, 90); // left

    // Blue crossbar pointing inward from the right edge.
    final barPaint = Paint()
      ..color = _blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;
    canvas.drawLine(
      Offset(size.width / 2, size.height / 2),
      Offset(size.width - stroke / 2, size.height / 2),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(_GoogleGPainter oldDelegate) => false;
}
