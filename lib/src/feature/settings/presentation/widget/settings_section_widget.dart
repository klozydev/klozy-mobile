import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';

class SettingsSectionWidget extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsSectionWidget({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontFamily: dsFontFamily,
              fontSize: DSFontSize.bodySmall,
              fontWeight: DSFontWeight.semiBold,
              letterSpacing: 0.6,
              color: DSColor.onSurface45,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: DSColor.card,
            borderRadius: BorderRadius.circular(DSBorderRadius.card),
            border: Border.all(color: DSColor.onSurface07, width: 0.5),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}
