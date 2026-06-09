import 'package:flutter/material.dart';

/// Font size scale (Poppins). Sizes match klozy usage (11..24px range).
abstract final class DSFontSize {
  static const double bodySmall = 11;
  static const double bodyMedium = 13;
  static const double bodyLarge = 14;
  static const double titleLarge = 16;
  static const double headlineLarge = 20;
  static const double displayLarge = 24;
}

/// Absolute line heights (logical px) paired 1:1 with [DSFontSize].
abstract final class DSFontLineHeight {
  static const double bodySmall = 14;
  static const double bodyMedium = 18;
  static const double bodyLarge = 20;
  static const double titleLarge = 22;
  static const double headlineLarge = 26;
  static const double displayLarge = 30;
}

/// Flutter `TextStyle.height` is a multiplier (line / size).
abstract final class DSFontHeight {
  static const double bodySmall =
      DSFontLineHeight.bodySmall / DSFontSize.bodySmall;
  static const double bodyMedium =
      DSFontLineHeight.bodyMedium / DSFontSize.bodyMedium;
  static const double bodyLarge =
      DSFontLineHeight.bodyLarge / DSFontSize.bodyLarge;
  static const double titleLarge =
      DSFontLineHeight.titleLarge / DSFontSize.titleLarge;
  static const double headlineLarge =
      DSFontLineHeight.headlineLarge / DSFontSize.headlineLarge;
  static const double displayLarge =
      DSFontLineHeight.displayLarge / DSFontSize.displayLarge;
}

/// Named weight aliases. Use `DSFontWeight.medium` instead of `FontWeight.w500`
/// at call sites so weight semantics live in one place.
abstract final class DSFontWeight {
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
}

/// Canonical font family key. Poppins is loaded at runtime by `google_fonts`
/// in `dsTheme()` (which registers the family + the weights below under this
/// exact name), so `TextStyle(fontFamily: dsFontFamily, ...)` resolves to it
/// without bundling `.ttf` assets.
const String dsFontFamily = 'Poppins';

/// Weights the DS actually renders. `dsTheme()` warms each one through
/// `google_fonts` so direct `TextStyle(fontFamily: dsFontFamily, fontWeight: …)`
/// call sites get the real Poppins glyphs (not a synthesized fallback).
const List<FontWeight> dsFontWeights = <FontWeight>[
  DSFontWeight.regular,
  DSFontWeight.medium,
  DSFontWeight.semiBold,
  DSFontWeight.bold,
];
