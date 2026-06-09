import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';

/// Reel overflow menu body — Delete (owner) or Report (others).
class ReelMenuSheet extends StatelessWidget {
  final bool isOwner;
  final VoidCallback onDelete;
  final VoidCallback onReport;

  const ReelMenuSheet({
    super.key,
    required this.isOwner,
    required this.onDelete,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (isOwner)
          _row(
            icon: Icons.delete_outline_rounded,
            label: context.l10N.reels_delete_reel,
            onTap: onDelete,
          )
        else
          _row(
            icon: Icons.flag_outlined,
            label: context.l10N.reels_report_reel,
            onTap: onReport,
          ),
      ],
    );
  }

  Widget _row({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
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
