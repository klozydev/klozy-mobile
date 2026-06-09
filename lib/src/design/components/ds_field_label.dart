import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';

/// Form field label with an optional required asterisk and a trailing [suffix]
/// (e.g. a "45/150" char counter). Mirrors the prototype `KFieldLabel`.
class DSFieldLabel extends StatelessWidget {
  final String text;
  final bool required;
  final Widget? suffix;

  const DSFieldLabel(
    this.text, {
    super.key,
    this.required = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DSSpacing.xxs),
      child: Row(
        children: <Widget>[
          Text.rich(
            TextSpan(
              text: text,
              style: const TextStyle(
                fontFamily: dsFontFamily,
                fontSize: DSFontSize.bodyLarge,
                fontWeight: DSFontWeight.semiBold,
                color: DSColor.onSurface,
                letterSpacing: -0.14,
              ),
              children: required
                  ? const <TextSpan>[
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: DSColor.onSurface45),
                      ),
                    ]
                  : null,
            ),
          ),
          if (suffix != null) ...<Widget>[const Spacer(), suffix!],
        ],
      ),
    );
  }
}
