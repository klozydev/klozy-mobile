import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_sparkle.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';

/// "Suggested by AI" marker shown on AI-filled fields. Matches the prototype's
/// sparkle tag (single, consistent badge across every AI field).
class SellFieldAiBadgeWidget extends StatelessWidget {
  const SellFieldAiBadgeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const DSSparkle(size: 11),
        const SizedBox(width: 4),
        Text(
          context.l10N.sell_suggested_by_ai,
          style: const TextStyle(
            fontFamily: dsFontFamily,
            fontSize: 10.5,
            fontWeight: DSFontWeight.semiBold,
            color: DSColor.primary,
          ),
        ),
      ],
    );
  }
}
