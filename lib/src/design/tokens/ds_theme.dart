import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:klozy/src/design/app_theme.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';

/// Returns the design-system [ThemeData].
///
/// Single mode — klozy renders white-on-black with a gold accent. There
/// is no light/dark split. Surface is `Colors.black`, primary is the
/// brand gold, font family is Poppins (loaded at runtime via `google_fonts`).
ThemeData dsTheme() {
  const colorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: DSColor.primary,
    onPrimary: DSColor.surface,
    secondary: DSColor.primary,
    onSecondary: DSColor.surface,
    tertiary: DSColor.lowBlack,
    onTertiary: DSColor.onSurface,
    surface: DSColor.surface,
    onSurface: DSColor.onSurface,
    error: DSColor.danger,
    onError: DSColor.onSurface,
  );

  // Warm every weight the DS renders so direct
  // `TextStyle(fontFamily: dsFontFamily, fontWeight: …)` call sites in the
  // components get real Poppins glyphs instead of a synthesized fallback.
  for (final weight in dsFontWeights) {
    GoogleFonts.poppins(fontWeight: weight);
  }

  // Each role goes through `google_fonts` so Poppins is registered under the
  // `dsFontFamily` ('Poppins') name and resolves everywhere in the tree.
  TextStyle ts({
    required double size,
    required double height,
    required FontWeight weight,
    Color color = DSColor.onSurface,
  }) => GoogleFonts.poppins(
    fontSize: size,
    height: height,
    fontWeight: weight,
    color: color,
  );

  final textTheme = TextTheme(
    displayLarge: ts(
      size: DSFontSize.displayLarge,
      height: DSFontHeight.displayLarge,
      weight: DSFontWeight.semiBold,
    ),
    headlineLarge: ts(
      size: DSFontSize.headlineLarge,
      height: DSFontHeight.headlineLarge,
      weight: DSFontWeight.semiBold,
    ),
    titleLarge: ts(
      size: DSFontSize.titleLarge,
      height: DSFontHeight.titleLarge,
      weight: DSFontWeight.semiBold,
    ),
    bodyLarge: ts(
      size: DSFontSize.bodyLarge,
      height: DSFontHeight.bodyLarge,
      weight: DSFontWeight.medium,
    ),
    bodyMedium: ts(
      size: DSFontSize.bodyMedium,
      height: DSFontHeight.bodyMedium,
      weight: DSFontWeight.regular,
    ),
    bodySmall: ts(
      size: DSFontSize.bodySmall,
      height: DSFontHeight.bodySmall,
      weight: DSFontWeight.regular,
    ),
  );

  return ThemeData(
    useMaterial3: false,
    fontFamily: dsFontFamily,
    scaffoldBackgroundColor: DSColor.surface,
    splashColor: Colors.transparent,
    hoverColor: Colors.transparent,
    focusColor: Colors.transparent,
    colorScheme: colorScheme,
    textTheme: textTheme,
    extensions: const <ThemeExtension<dynamic>>[AppTheme.dark()],
    appBarTheme: const AppBarTheme(
      backgroundColor: DSColor.surface,
      foregroundColor: DSColor.onSurface,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: DSColor.onSurface),
    ),
  );
}
