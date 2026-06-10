import 'dart:ui' as ui;

import 'package:core_kosmos/core_kosmos.dart';
import 'package:flutter/material.dart';

/// White text style helper for offer/purchase message bubbles (ported from
/// klozy's DefaultAppStyle.white). Uses responsive `sp()` sizing.
TextStyle chatWhiteStyle(double size, [FontWeight weight = FontWeight.normal]) {
  return TextStyle(
    color: Colors.white,
    fontSize: sp(size),
    fontWeight: weight,
    fontFamily: 'Poppins',
  );
}

/// Measures the rendered width of [text] in [style], capped at [maxWidth]
/// (ported from klozy's getTextWidth) — used to size the purchase divider.
double chatTextWidth(String text, TextStyle style, double maxWidth) {
  final TextPainter painter = TextPainter(
    textWidthBasis: TextWidthBasis.longestLine,
    text: TextSpan(text: text, style: style),
    textDirection: ui.TextDirection.ltr,
  )..layout(minWidth: 0, maxWidth: maxWidth);
  return painter.size.width;
}
