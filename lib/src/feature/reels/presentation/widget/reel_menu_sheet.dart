import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';

/// Reel overflow menu body — Edit + Share + Delete (owner) or Share + Report
/// (others).
class ReelMenuSheet extends StatelessWidget {
  final bool isOwner;
  final VoidCallback? onEdit;
  final VoidCallback onShare;
  final VoidCallback onDelete;
  final VoidCallback onReport;

  const ReelMenuSheet({
    super.key,
    required this.isOwner,
    required this.onShare,
    required this.onDelete,
    required this.onReport,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (isOwner) ...<Widget>[
          if (onEdit != null)
            _row(
              icon: Icons.edit_outlined,
              label: context.l10N.reels_edit_reel,
              color: DSColor.onSurface,
              onTap: onEdit!,
            ),
          _row(
            icon: Icons.ios_share_rounded,
            label: context.l10N.reels_share,
            color: DSColor.onSurface,
            onTap: onShare,
          ),
          _row(
            icon: Icons.delete_outline_rounded,
            label: context.l10N.reels_delete_reel,
            color: DSColor.danger,
            onTap: onDelete,
          ),
        ] else ...<Widget>[
          _row(
            icon: Icons.ios_share_rounded,
            label: context.l10N.reels_share,
            color: DSColor.onSurface,
            onTap: onShare,
          ),
          _row(
            icon: Icons.flag_outlined,
            label: context.l10N.reels_report_reel,
            color: DSColor.danger,
            onTap: onReport,
          ),
        ],
      ],
    );
  }

  Widget _row({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                fontFamily: dsFontFamily,
                fontSize: DSFontSize.bodyLarge,
                fontWeight: DSFontWeight.medium,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
