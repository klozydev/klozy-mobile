import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';

/// A horizontal rule with centered text, e.g. "or continue with". Mirrors the
/// prototype `OrDivider`.
class DSOrDivider extends StatelessWidget {
  final String label;

  const DSOrDivider({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Expanded(child: Divider(height: 0.5, color: DSColor.onSurface12)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: dsFontFamily,
              fontSize: DSFontSize.bodyMedium,
              fontWeight: DSFontWeight.medium,
              color: DSColor.onSurface35,
            ),
          ),
        ),
        const Expanded(child: Divider(height: 0.5, color: DSColor.onSurface12)),
      ],
    );
  }
}
