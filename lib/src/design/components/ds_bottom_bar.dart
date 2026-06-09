import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';

/// Fixed bottom action area with a hairline top border. Holds the primary CTA
/// (and optional helper text) above the safe-area inset. Mirrors `KBottomBar`.
class DSBottomBar extends StatelessWidget {
  final Widget child;

  const DSBottomBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: DSColor.surface,
        border: Border(top: BorderSide(color: DSColor.onSurface08, width: 0.5)),
      ),
      padding: EdgeInsets.fromLTRB(
        DSSpacing.s,
        DSSpacing.xs,
        DSSpacing.s,
        DSSpacing.l + MediaQuery.viewPaddingOf(context).bottom,
      ),
      child: child,
    );
  }
}
