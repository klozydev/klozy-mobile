import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';

/// Product overflow menu — owner (edit / mark sold-available / delete) or
/// non-owner (report).
class ProductMenuSheet extends StatelessWidget {
  final bool isOwner;
  final bool isSold;
  final VoidCallback onEdit;
  final VoidCallback onToggleSold;
  final VoidCallback onDelete;
  final VoidCallback onReport;

  const ProductMenuSheet({
    super.key,
    required this.isOwner,
    required this.isSold,
    required this.onEdit,
    required this.onToggleSold,
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
                Icons.shopping_bag_outlined,
                isSold
                    ? context.l10N.product_mark_as_available
                    : context.l10N.product_mark_as_sold,
                onToggleSold,
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
