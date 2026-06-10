import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';

class PersonalizeRemovableChipWidget extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const PersonalizeRemovableChipWidget({
    super.key,
    required this.label,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRemove,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: DSColor.primary,
          borderRadius: BorderRadius.circular(DSBorderRadius.chip),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              label,
              style: const TextStyle(
                fontFamily: dsFontFamily,
                fontSize: DSFontSize.bodyMedium,
                fontWeight: DSFontWeight.semiBold,
                color: DSColor.surface,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.close, size: 14, color: DSColor.surface),
          ],
        ),
      ),
    );
  }
}
