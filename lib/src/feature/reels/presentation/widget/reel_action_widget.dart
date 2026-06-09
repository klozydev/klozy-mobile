import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';

/// One item in the reel right-hand action rail (icon + optional count label).
class ReelActionWidget extends StatelessWidget {
  final IconData icon;
  final String? label;
  final Color color;
  final VoidCallback onTap;

  const ReelActionWidget({
    super.key,
    required this.icon,
    required this.onTap,
    this.label,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            size: 29,
            color: color,
            shadows: const <Shadow>[
              Shadow(color: Color(0x99000000), blurRadius: 6),
            ],
          ),
          if (label != null) ...<Widget>[
            const SizedBox(height: 5),
            Text(
              label!,
              style: const TextStyle(
                fontFamily: dsFontFamily,
                fontSize: 11,
                fontWeight: DSFontWeight.semiBold,
                color: Colors.white,
                shadows: <Shadow>[
                  Shadow(color: Color(0x99000000), blurRadius: 4),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
