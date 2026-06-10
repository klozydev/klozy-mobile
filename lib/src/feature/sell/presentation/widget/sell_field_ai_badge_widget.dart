import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';

/// Sparkle icon badge shown on AI-filled fields.
class SellFieldAiBadgeWidget extends StatelessWidget {
  const SellFieldAiBadgeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.xxs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: DSColor.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(DSBorderRadius.image),
        border: Border.all(color: DSColor.primary.withOpacity(0.5)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.auto_awesome, size: 12, color: DSColor.primary),
          SizedBox(width: 2),
          Text(
            'AI',
            style: TextStyle(
              fontFamily: dsFontFamily,
              fontSize: DSFontSize.bodySmall,
              fontWeight: DSFontWeight.semiBold,
              color: DSColor.primary,
            ),
          ),
        ],
      ),
    );
  }
}
