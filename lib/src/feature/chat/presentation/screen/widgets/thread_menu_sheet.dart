import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/thread_menu_choice.dart';

/// Thread overflow menu: report & block, delete conversation (both
/// destructive). Pops the chosen [ThreadMenuChoice].
class ThreadMenuSheet extends StatelessWidget {
  const ThreadMenuSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _MenuRow(
          icon: Icons.flag_outlined,
          label: context.l10N.chat_menu_report,
          onTap: () =>
              Navigator.of(context).pop(ThreadMenuChoice.reportAndBlock),
        ),
        _MenuRow(
          icon: Icons.delete_outline,
          label: context.l10N.chat_menu_delete,
          onTap: () => Navigator.of(context).pop(ThreadMenuChoice.delete),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        child: Row(
          children: <Widget>[
            Icon(icon, color: DSColor.danger, size: 20),
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
