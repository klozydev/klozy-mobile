import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';

class PersonalizeSectionTitleWidget extends StatelessWidget {
  final String title;
  final String? hint;
  final Widget? trailing;

  const PersonalizeSectionTitleWidget({
    super.key,
    required this.title,
    this.hint,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: DSSpacing.l, bottom: DSSpacing.xs),
      child: Row(
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              fontFamily: dsFontFamily,
              fontSize: DSFontSize.titleLarge,
              fontWeight: DSFontWeight.semiBold,
              letterSpacing: -0.16,
              color: DSColor.onSurface,
            ),
          ),
          if (hint != null) ...<Widget>[
            const SizedBox(width: DSSpacing.xxs),
            Text(
              hint!,
              style: const TextStyle(
                fontFamily: dsFontFamily,
                fontSize: DSFontSize.bodySmall,
                color: DSColor.onSurface35,
              ),
            ),
          ],
          if (trailing != null) ...<Widget>[const Spacer(), trailing!],
        ],
      ),
    );
  }
}
