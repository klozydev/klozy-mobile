import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';

/// Full-width social sign-in button (subtle fill + hairline border) with a
/// brand [icon] + label. Mirrors the prototype `SocialButton`.
class DSSocialButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback? onPressed;

  const DSSocialButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: Material(
        color: DSColor.onSurface07,
        borderRadius: BorderRadius.circular(DSBorderRadius.input),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(DSBorderRadius.input),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DSBorderRadius.input),
              border: Border.all(color: DSColor.onSurface12, width: 0.5),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                icon,
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: dsFontFamily,
                    fontSize: DSFontSize.bodyLarge,
                    fontWeight: DSFontWeight.semiBold,
                    color: DSColor.onSurface,
                    letterSpacing: -0.14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
