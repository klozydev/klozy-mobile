import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';

class ProfileMenuSheet extends StatelessWidget {
  final VoidCallback onReport;
  final VoidCallback onBlock;

  const ProfileMenuSheet({
    super.key,
    required this.onReport,
    required this.onBlock,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _MenuRow(
          icon: Icons.block_outlined,
          label: context.l10N.profile_block_user,
          onTap: onBlock,
        ),
        _MenuRow(
          icon: Icons.flag_outlined,
          label: context.l10N.profile_report_user,
          onTap: onReport,
        ),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 20, color: DSColor.danger),
            const SizedBox(width: 14),
            Text(
              label,
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
    );
  }
}
