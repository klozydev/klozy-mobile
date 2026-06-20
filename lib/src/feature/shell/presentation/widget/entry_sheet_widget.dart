import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/feature/shell/presentation/widget/entry_choice.dart';

/// Body of the "What would you like to do?" entry sheet shown from the bottom
/// nav "+". Two rows — create a reel or list an item — each popping the sheet
/// with the chosen [EntryChoice].
class EntrySheetWidget extends StatelessWidget {
  const EntrySheetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _EntryRow(
          icon: Icons.image_outlined,
          tint: DSColor.onSurface,
          background: DSColor.onSurface07,
          label: context.l10N.entry_create_reel,
          sub: context.l10N.entry_create_reel_sub,
          onTap: () => Navigator.of(context).pop(EntryChoice.reel),
        ),
        const Divider(height: 0.5, thickness: 0.5, color: DSColor.onSurface08),
        _EntryRow(
          icon: Icons.local_offer_outlined,
          tint: DSColor.primary,
          background: const Color(0x21E0CE7D),
          label: context.l10N.entry_list_item,
          sub: context.l10N.entry_list_item_sub,
          onTap: () => Navigator.of(context).pop(EntryChoice.sell),
        ),
        const SizedBox(height: 8),
        // Explicit full-width Cancel button (mirrors the design's bottom row).
        GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: Container(
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: DSColor.card,
              borderRadius: BorderRadius.circular(DSBorderRadius.input),
              border: Border.all(color: DSColor.onSurface08, width: 0.5),
            ),
            child: Text(
              context.l10N.entry_cancel,
              style: const TextStyle(
                fontFamily: dsFontFamily,
                fontSize: DSFontSize.bodyLarge,
                fontWeight: DSFontWeight.semiBold,
                color: DSColor.onSurface75,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EntryRow extends StatelessWidget {
  final IconData icon;
  final Color tint;
  final Color background;
  final String label;
  final String sub;
  final VoidCallback onTap;

  const _EntryRow({
    required this.icon,
    required this.tint,
    required this.background,
    required this.label,
    required this.sub,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: <Widget>[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, size: 21, color: tint),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: dsFontFamily,
                      fontSize: DSFontSize.bodyLarge,
                      fontWeight: DSFontWeight.semiBold,
                      color: DSColor.onSurface,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    sub,
                    style: const TextStyle(
                      fontFamily: dsFontFamily,
                      fontSize: DSFontSize.bodyMedium,
                      color: DSColor.onSurface45,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: DSColor.onSurface24,
            ),
          ],
        ),
      ),
    );
  }
}
