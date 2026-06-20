import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';

/// Persistent search bar shown on Home below the tab nav. Non-interactive by
/// default: a tap navigates to the search tab; the trailing camera button
/// triggers visual search. Ports the prototype/reference `DSSearchBar`.
class DSSearchBar extends StatelessWidget {
  final String placeholder;
  final VoidCallback? onTap;
  final VoidCallback? onCameraTap;

  const DSSearchBar({
    super.key,
    required this.placeholder,
    this.onTap,
    this.onCameraTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.xs,
          vertical: DSSpacing.xxs + 2,
        ),
        decoration: BoxDecoration(
          color: DSColor.card,
          borderRadius: BorderRadius.circular(DSBorderRadius.input),
          border: Border.all(color: DSColor.onSurface10, width: 0.5),
        ),
        child: Row(
          children: <Widget>[
            const Icon(
              Icons.search_rounded,
              size: 16,
              color: DSColor.onSurface45,
            ),
            const SizedBox(width: DSSpacing.xxs),
            Expanded(
              child: Text(
                placeholder,
                style: const TextStyle(
                  fontFamily: dsFontFamily,
                  fontSize: DSFontSize.bodyMedium,
                  color: DSColor.onSurface45,
                  height: DSFontHeight.bodyMedium,
                ),
              ),
            ),
            GestureDetector(
              onTap: onCameraTap,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: DSColor.onSurface07,
                  borderRadius: BorderRadius.circular(DSBorderRadius.light),
                  border: Border.all(color: DSColor.onSurface10, width: 0.5),
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  size: 15,
                  color: DSColor.onSurface65,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
