import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';

class FilterSectionLabelWidget extends StatelessWidget {
  final String text;

  const FilterSectionLabelWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 12),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontFamily: dsFontFamily,
          fontSize: 11,
          fontWeight: DSFontWeight.semiBold,
          letterSpacing: 0.88,
          color: DSColor.onSurface35,
        ),
      ),
    );
  }
}
