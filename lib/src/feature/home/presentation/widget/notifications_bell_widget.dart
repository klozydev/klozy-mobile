import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';

/// Home-header bell with an unread-count badge.
class NotificationsBellWidget extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const NotificationsBellWidget({
    super.key,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            const Icon(
              Icons.notifications_none_rounded,
              size: 24,
              color: DSColor.onSurface,
            ),
            if (count > 0)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  constraints: const BoxConstraints(minWidth: 16),
                  height: 16,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: DSColor.primary,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: DSColor.surface, width: 1.5),
                  ),
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    style: const TextStyle(
                      fontFamily: dsFontFamily,
                      fontSize: 9,
                      fontWeight: DSFontWeight.bold,
                      color: DSColor.surface,
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
