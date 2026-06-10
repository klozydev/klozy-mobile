import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';

class SelectedCategoryChipWidget extends StatelessWidget {
  final String path;
  final VoidCallback onClear;

  const SelectedCategoryChipWidget({
    super.key,
    required this.path,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            path,
            style: const TextStyle(
              fontFamily: dsFontFamily,
              fontSize: DSFontSize.bodyMedium,
              fontWeight: DSFontWeight.medium,
              color: DSColor.primary,
            ),
          ),
        ),
        GestureDetector(
          onTap: onClear,
          child: const Icon(Icons.close, size: 18, color: DSColor.onSurface45),
        ),
      ],
    );
  }
}
