import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The Klozy brand logo: the `KLAZY` wordmark (white lettering + gold dot) that
/// also forms the app icon, vectorized to `assets/svg/logo_klozy.svg` so it
/// renders on a transparent background and stays crisp at any size. Single
/// source of truth — use this everywhere the Klozy logo appears. [size] is the
/// wordmark height; width follows its aspect ratio.
class DSAppLogo extends StatelessWidget {
  const DSAppLogo({super.key, this.size = 44});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/svg/logo_klozy.svg',
      height: size,
      fit: BoxFit.contain,
    );
  }
}
