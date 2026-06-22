import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';

/// Product overflow menu — owner (edit / delete) or non-owner (report).
/// A listing is marked SOLD only by a completed purchase (server-side), never
/// from here, so there is no manual mark-sold action.
class ProductMenuSheet extends StatelessWidget {
  final bool isOwner;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onReport;

  const ProductMenuSheet({
    super.key,
    required this.isOwner,
    required this.onEdit,
    required this.onDelete,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: isOwner
          ? <Widget>[
              _row(
                Icons.edit_outlined,
                context.l10N.product_edit_listing,
                onEdit,
              ),
              _row(
                Icons.delete_outline_rounded,
                context.l10N.product_delete_listing,
                onDelete,
                danger: true,
              ),
            ]
          : <Widget>[
              _row(
                Icons.flag_outlined,
                context.l10N.product_report_listing,
                onReport,
                danger: true,
              ),
            ],
    );
  }

  Widget _row(
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool danger = false,
  }) {
    final color = danger ? DSColor.danger : DSColor.onSurface;
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
