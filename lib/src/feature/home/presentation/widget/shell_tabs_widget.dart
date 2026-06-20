import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';

/// The Home top tabs — Feed / Wishlist / Reels — with an underline indicator.
class ShellTabsWidget extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  /// When true the tabs sit over the full-bleed Reels video, so labels render
  /// white (with a soft shadow) instead of on the surface colour.
  final bool overlay;

  const ShellTabsWidget({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
    this.overlay = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color selected = overlay ? Colors.white : DSColor.onSurface;
    final Color unselected = overlay
        ? Colors.white.withValues(alpha: 0.6)
        : DSColor.onSurface35;
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for (int i = 0; i < tabs.length; i++)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onChanged(i),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 11),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    tabs[i],
                    style: TextStyle(
                      fontFamily: dsFontFamily,
                      fontSize: DSFontSize.titleLarge,
                      fontWeight: i == selectedIndex
                          ? DSFontWeight.bold
                          : DSFontWeight.semiBold,
                      color: i == selectedIndex ? selected : unselected,
                      shadows: overlay
                          ? const <Shadow>[
                              Shadow(color: Color(0x99000000), blurRadius: 4),
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 2,
                    width: i == selectedIndex ? 20 : 0,
                    decoration: BoxDecoration(
                      color: DSColor.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
