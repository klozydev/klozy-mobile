import 'dart:ui' as ui;

import 'package:core_kosmos/core_kosmos.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';

/// White text style helper for offer/purchase message bubbles on the dark
/// "other" bubble (ported from klozy's DefaultAppStyle.white). Responsive `sp()`.
TextStyle chatWhiteStyle(double size, [FontWeight weight = FontWeight.normal]) {
  return TextStyle(
    color: Colors.white,
    fontSize: sp(size),
    fontWeight: weight,
    fontFamily: 'Poppins',
  );
}

/// Dark text for the gold "me" bubble — white-on-gold is unreadable, so my own
/// offer/purchase bubbles use the surface colour instead.
TextStyle chatOnPrimaryStyle(
  double size, [
  FontWeight weight = FontWeight.normal,
]) {
  return TextStyle(
    color: DSColor.surface,
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
