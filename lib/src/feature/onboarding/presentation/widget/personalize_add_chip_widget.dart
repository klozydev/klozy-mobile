import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';

class PersonalizeAddChipWidget extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const PersonalizeAddChipWidget({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: DSColor.onSurface07,
          borderRadius: BorderRadius.circular(DSBorderRadius.chip),
          border: Border.all(color: DSColor.onSurface15, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.add, size: 14, color: DSColor.onSurface60),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontFamily: dsFontFamily,
                fontSize: DSFontSize.bodyMedium,
                fontWeight: DSFontWeight.medium,
                color: DSColor.onSurface75,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
