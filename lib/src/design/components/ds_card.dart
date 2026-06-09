import 'package:flutter/material.dart';

import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';

class DSCard extends StatelessWidget {
  final Widget _child;
  final double _borderRadius;
  final EdgeInsetsGeometry _padding;

  const DSCard({
    super.key,
    required Widget child,
    double borderRadius = DSBorderRadius.cardSmall,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(
      horizontal: DSSpacing.s,
      vertical: DSSpacing.xs,
    ),
  }) : _child = child,
       _borderRadius = borderRadius,
       _padding = padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: _padding,
      decoration: BoxDecoration(
        color: DSColor.card,
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
      child: _child,
    );
  }
}
