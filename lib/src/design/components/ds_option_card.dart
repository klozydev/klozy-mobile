import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';

/// Selectable option card: leading icon tile, title (+ optional badge),
/// description, and a trailing radio. Used by the seller-role fork. Mirrors the
/// prototype `OptionCard`.
class DSOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? badge;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  const DSOptionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  static const Color _selectedTint = Color(0x14E0CE7D); // 8%
  static const Color _badgeTint = Color(0x1FE0CE7D); // 12%

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? _selectedTint : DSColor.card,
          borderRadius: BorderRadius.circular(DSBorderRadius.card),
          border: Border.all(
            color: selected ? DSColor.primary : DSColor.onSurface08,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: selected ? DSColor.primary : DSColor.onSurface07,
                borderRadius: BorderRadius.circular(DSBorderRadius.image),
                border: selected
                    ? null
                    : Border.all(color: DSColor.onSurface12, width: 0.5),
              ),
              child: Icon(
                icon,
                size: 22,
                color: selected ? DSColor.surface : DSColor.onSurface75,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontFamily: dsFontFamily,
                            fontSize: DSFontSize.titleLarge,
                            fontWeight: DSFontWeight.semiBold,
                            color: DSColor.onSurface,
                            letterSpacing: -0.16,
                          ),
                        ),
                      ),
                      if (badge != null) ...<Widget>[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _badgeTint,
                            borderRadius: BorderRadius.circular(
                              DSBorderRadius.chip,
                            ),
                          ),
                          child: Text(
                            badge!.toUpperCase(),
                            style: const TextStyle(
                              fontFamily: dsFontFamily,
                              fontSize: 9,
                              fontWeight: DSFontWeight.bold,
                              letterSpacing: 0.72,
                              color: DSColor.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontFamily: dsFontFamily,
                      fontSize: DSFontSize.bodyMedium,
                      fontWeight: DSFontWeight.regular,
                      height: 1.38,
                      color: DSColor.onSurface60,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 22,
              height: 22,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? DSColor.primary : Colors.transparent,
                border: Border.all(
                  color: selected ? DSColor.primary : DSColor.onSurface24,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 13, color: DSColor.surface)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
