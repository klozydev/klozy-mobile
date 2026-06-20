import 'package:flutter/material.dart';

abstract final class DSColor {
  // MARK: Brand
  static const Color primary = Color(0xFFE0CE7D);
  static const Color brandGlow = Color(0x33E0CE7D);

  // MARK: Surfaces
  static const Color surface = Colors.black;
  static const Color onSurface = Colors.white;
  static const Color card = Color(0xFF141414);
  static const Color lowBlack = Color(0xFF2E2E2E);
  static const Color popupBackground = Color(0xFF222222);

  // MARK: Semantic
  static const Color danger = Color(0xFFEB5353);
  static const Color destructive = Color(0xFFDB3D2E);

  // MARK: Avatar
  static const Color avatarGradientStart = Color(0xFF4A90E2);
  static const Color avatarGradientEnd = Color(0xFF2C5AA0);

  // MARK: Alpha-ed whites
  static const Color onSurface05 = Color(0x0DFFFFFF); // 5%
  static const Color onSurface06 = Color(0x0FFFFFFF); // 6%
  static const Color onSurface07 = Color(0x12FFFFFF); // 7%
  static const Color onSurface08 = Color(0x14FFFFFF); // 8%
  static const Color onSurface10 = Color(0x1AFFFFFF); // 10%
  static const Color onSurface12 = Color(0x1FFFFFFF); // 12%
  static const Color onSurface15 = Color(0x26FFFFFF); // 15%
  static const Color onSurface24 = Color(0x3DFFFFFF); // 24%
  static const Color onSurface35 = Color(0x59FFFFFF); // 35%
  static const Color onSurface45 = Color(0x73FFFFFF); // 45%
  static const Color onSurface60 = Color(0x99FFFFFF); // 60%
  static const Color onSurface65 = Color(0xA6FFFFFF); // 65%
  static const Color onSurface75 = Color(0xBFFFFFFF); // 75%
  static const Color onSurface85 = Color(0xD9FFFFFF); // 85%
}
