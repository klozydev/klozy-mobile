import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';

/// The Home top tabs — Feed / Wishlist / Reels — with an underline indicator.
class ShellTabsWidget extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const ShellTabsWidget({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        for (int i = 0; i < tabs.length; i++)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onChanged(i),
            child: Padding(
              padding: const EdgeInsets.only(right: 22),
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
                      color: i == selectedIndex
                          ? DSColor.onSurface
                          : DSColor.onSurface35,
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
