import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';

/// A 38px circular action button used in the profile app bar
/// (bag / bell / gear for self, more-menu for public).
///
/// Matches the design `CircleBtn`: 38×38 circle, 7% white fill,
/// 0.5px 10% white border, optional unread badge dot.
class ProfileCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool showBadge;

  const ProfileCircleButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: DSColor.onSurface07,
          shape: BoxShape.circle,
          border: Border.all(color: DSColor.onSurface10, width: 0.5),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Icon(icon, size: 19, color: DSColor.onSurface),
            if (showBadge)
              Positioned(
                top: 7,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: DSColor.danger,
                    shape: BoxShape.circle,
                    border: Border.all(color: DSColor.surface, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
