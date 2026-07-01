import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';

/// A single bottom-nav destination: an icon that turns gold when active, with
/// an optional unread/count badge (chat).
class ShellNavItemWidget extends StatelessWidget {
  static const double _iconSize = 24;

  final String assetPath;
  final bool active;
  final VoidCallback onTap;
  final int badge;

  const ShellNavItemWidget({
    super.key,
    required this.assetPath,
    required this.active,
    required this.onTap,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            SvgPicture.asset(
              assetPath,
              width: _iconSize,
              height: _iconSize,
              colorFilter: ColorFilter.mode(
                active ? DSColor.primary : DSColor.onSurface45,
                BlendMode.srcIn,
              ),
            ),
            if (badge > 0)
              Positioned(
                top: -3,
                right: -7,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 16),
                  height: 16,
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: DSColor.primary,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: DSColor.surface, width: 1.5),
                  ),
                  child: Text(
                    badge > 9 ? '9+' : '$badge',
                    style: const TextStyle(
                      fontFamily: dsFontFamily,
                      fontSize: 9,
                      fontWeight: DSFontWeight.bold,
                      color: DSColor.surface,
                      height: 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
