import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_selectable_chip.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';
import 'package:klozy/src/feature/sell/domain/entity/size_system.dart';

/// EU / US size system toggle.
class SellSizeToggleWidget extends StatelessWidget {
  final SizeSystem current;
  final void Function(SizeSystem) onToggle;

  const SellSizeToggleWidget({
    super.key,
    required this.current,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          context.l10N.sellSizeSystem,
          style: const TextStyle(
            fontFamily: dsFontFamily,
            fontSize: DSFontSize.bodyMedium,
            fontWeight: DSFontWeight.medium,
            color: DSColor.onSurface75,
          ),
        ),
        const SizedBox(width: DSSpacing.xxs),
        DSSelectableChip(
          label: 'EU',
          selected: current == SizeSystem.eu,
          onTap: () => onToggle(SizeSystem.eu),
        ),
        const SizedBox(width: DSSpacing.xxxs),
        DSSelectableChip(
          label: 'US',
          selected: current == SizeSystem.us,
          onTap: () => onToggle(SizeSystem.us),
        ),
      ],
    );
  }
}
