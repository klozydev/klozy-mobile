import 'package:flutter/material.dart';

import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';

class DSChip extends StatelessWidget {
  final String _label;

  const DSChip({super.key, required String label}) : _label = label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.xxs,
        vertical: DSSpacing.xxxs,
      ),
      decoration: BoxDecoration(
        color: DSColor.onSurface07,
        borderRadius: BorderRadius.circular(DSBorderRadius.chip),
        border: Border.all(color: DSColor.onSurface08, width: 0.5),
      ),
      child: Text(
        _label,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: DSColor.onSurface75),
      ),
    );
  }
}
