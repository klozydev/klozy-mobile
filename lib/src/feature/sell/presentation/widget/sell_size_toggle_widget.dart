import 'package:flutter/material.dart';
import 'package:klozy/src/design/components/ds_selectable_chip.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';
import 'package:klozy/src/feature/sell/domain/entity/size_system.dart';

/// EU / UK / US size system toggle — sits inline next to the size label
/// (design: segmented control, no standalone "Size system" caption).
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
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        DSSelectableChip(
          label: 'EU',
          selected: current == SizeSystem.eu,
          onTap: () => onToggle(SizeSystem.eu),
        ),
        const SizedBox(width: DSSpacing.xxxs),
        DSSelectableChip(
          label: 'UK',
          selected: current == SizeSystem.uk,
          onTap: () => onToggle(SizeSystem.uk),
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
