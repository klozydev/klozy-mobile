import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';

/// Center Sell action in the bottom nav — a gold circular FAB with a soft glow.
/// Pushes the sell flow rather than switching tabs.
class ShellSellFabWidget extends StatelessWidget {
  static const double _iconSize = 24;

  final VoidCallback onTap;

  const ShellSellFabWidget({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          color: DSColor.primary,
          shape: BoxShape.circle,
          boxShadow: <BoxShadow>[
            BoxShadow(color: DSColor.brandGlow, blurRadius: 18),
          ],
        ),
        child: Center(
          child: SvgPicture.asset(
            'assets/svg/ic_add.svg',
            width: _iconSize,
            height: _iconSize,
          ),
        ),
      ),
    );
  }
}
