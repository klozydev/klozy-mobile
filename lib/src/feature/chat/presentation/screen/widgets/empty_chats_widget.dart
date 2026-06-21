import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';

/// Empty state for the messages list.
class EmptyChatsWidget extends StatelessWidget {
  const EmptyChatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DSSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.forum_outlined,
              color: DSColor.onSurface24,
              size: 48,
            ),
            const SizedBox(height: DSSpacing.s),
            Text(
              context.l10N.chat_empty_title,
              style: const TextStyle(
                fontFamily: dsFontFamily,
                fontSize: DSFontSize.bodyLarge,
                fontWeight: DSFontWeight.semiBold,
                color: DSColor.onSurface60,
              ),
            ),
            const SizedBox(height: DSSpacing.xxs),
            Text(
              context.l10N.chat_empty_subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: dsFontFamily,
                fontSize: DSFontSize.bodyMedium,
                color: DSColor.onSurface45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
