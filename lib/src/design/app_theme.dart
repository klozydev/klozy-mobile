import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';

/// Theme extension that exposes Klozy design tokens that don't fit
/// `ColorScheme` / `TextTheme` (lightbox backdrop, shimmer pair). Reach via
/// `context.appTheme`.
@immutable
class AppTheme extends ThemeExtension<AppTheme> {
  const AppTheme({
    required this.lightboxBackdrop,
    required this.shimmerBase,
    required this.shimmerHighlight,
  });

  /// Single Klozy theme — dark, gold accent.
  const AppTheme.dark()
    : lightboxBackdrop = const Color(0xF0000000),
      shimmerBase = DSColor.card,
      shimmerHighlight = DSColor.lowBlack;

  final Color lightboxBackdrop;
  final Color shimmerBase;
  final Color shimmerHighlight;

  @override
  AppTheme copyWith({
    Color? lightboxBackdrop,
    Color? shimmerBase,
    Color? shimmerHighlight,
  }) {
    return AppTheme(
      lightboxBackdrop: lightboxBackdrop ?? this.lightboxBackdrop,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
    );
  }

  @override
  AppTheme lerp(ThemeExtension<AppTheme>? other, double t) {
    if (other is! AppTheme) return this;
    return AppTheme(
      lightboxBackdrop: Color.lerp(
        lightboxBackdrop,
        other.lightboxBackdrop,
        t,
      )!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight: Color.lerp(
        shimmerHighlight,
        other.shimmerHighlight,
        t,
      )!,
    );
  }
}
