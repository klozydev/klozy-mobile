import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';

/// Selectable pill chip (gold when selected). Used for personalize categories,
/// sizes and conditions. Mirrors the prototype `KAttributeChip`.
class DSSelectableChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const DSSelectableChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? DSColor.primary : DSColor.card,
          borderRadius: BorderRadius.circular(DSBorderRadius.chip),
          border: selected
              ? null
              : Border.all(color: DSColor.onSurface15, width: 0.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: dsFontFamily,
            fontSize: DSFontSize.bodyMedium,
            height: DSFontHeight.bodyMedium,
            fontWeight: selected ? DSFontWeight.semiBold : DSFontWeight.medium,
            color: selected ? DSColor.surface : DSColor.onSurface75,
          ),
        ),
      ),
    );
  }
}
