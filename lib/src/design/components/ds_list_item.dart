import 'package:flutter/material.dart';

import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';

class DSListItem extends StatelessWidget {
  final String _title;
  final String? _subtitle;
  final Widget? _leading;
  final Widget? _trailing;
  final VoidCallback? _onTap;

  const DSListItem({
    super.key,
    required String title,
    String? subtitle,
    Widget? leading,
    Widget? trailing,
    VoidCallback? onTap,
  }) : _title = title,
       _subtitle = subtitle,
       _leading = leading,
       _trailing = trailing,
       _onTap = onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final leading = _leading;
    final subtitle = _subtitle;
    final trailing = _trailing;
    return InkWell(
      onTap: _onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: DSSpacing.xxxxl),
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.s,
          vertical: DSSpacing.xs,
        ),
        child: Row(
          children: [
            if (leading != null) ...[
              leading,
              const SizedBox(width: DSSpacing.xs),
            ],
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_title, style: textTheme.titleLarge),
                  if (subtitle != null) ...[
                    const SizedBox(height: DSSpacing.xxxs),
                    Text(
                      subtitle,
                      style: textTheme.bodyMedium?.copyWith(
                        color: DSColor.onSurface65,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: DSSpacing.xs),
              trailing,
            ],
          ],
        ),
      ),
    );
  }
}
