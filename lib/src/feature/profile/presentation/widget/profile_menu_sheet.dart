import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';

class ProfileMenuSheet extends StatelessWidget {
  final VoidCallback onReport;

  const ProfileMenuSheet({super.key, required this.onReport});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        InkWell(
          onTap: onReport,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.flag_outlined,
                  size: 20,
                  color: DSColor.danger,
                ),
                const SizedBox(width: 14),
                Text(
                  context.l10N.profile_report_user,
                  style: const TextStyle(
                    fontFamily: dsFontFamily,
                    fontSize: DSFontSize.bodyLarge,
                    fontWeight: DSFontWeight.medium,
                    color: DSColor.danger,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
