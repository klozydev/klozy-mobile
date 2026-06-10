import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';

class PersonalizeSubLabelWidget extends StatelessWidget {
  final String label;

  const PersonalizeSubLabelWidget({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DSSpacing.xxs),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: dsFontFamily,
          fontSize: DSFontSize.bodyMedium,
          color: DSColor.onSurface45,
        ),
      ),
    );
  }
}
