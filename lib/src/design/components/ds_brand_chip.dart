import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';

/// Selectable brand chip with a monogram avatar (first letter) + name. Mirrors
/// the prototype `BrandChip`.
class DSBrandChip extends StatelessWidget {
  final String name;
  final bool selected;
  final VoidCallback onTap;

  const DSBrandChip({
    super.key,
    required this.name,
    required this.selected,
    required this.onTap,
  });

  static const Color _selectedMono = Color(0x24000000); // black 14%

  @override
  Widget build(BuildContext context) {
    final Color fg = selected ? DSColor.surface : DSColor.onSurface75;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.fromLTRB(6, 6, 14, 6),
        decoration: BoxDecoration(
          color: selected ? DSColor.primary : DSColor.onSurface07,
          borderRadius: BorderRadius.circular(DSBorderRadius.chip),
          border: selected
              ? null
              : Border.all(color: DSColor.onSurface15, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? _selectedMono : DSColor.onSurface10,
              ),
              child: Text(
                name.isEmpty ? '?' : name.characters.first.toUpperCase(),
                style: TextStyle(
                  fontFamily: dsFontFamily,
                  fontSize: DSFontSize.bodySmall,
                  fontWeight: DSFontWeight.bold,
                  color: fg,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: TextStyle(
                fontFamily: dsFontFamily,
                fontSize: DSFontSize.bodyMedium,
                fontWeight: selected
                    ? DSFontWeight.semiBold
                    : DSFontWeight.medium,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
