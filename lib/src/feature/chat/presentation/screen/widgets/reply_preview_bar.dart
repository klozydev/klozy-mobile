import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_message.dart';

/// Strip shown above the composer when replying to a message: a quote snippet
/// plus a dismiss button. Cleared via [onCancel].
class ReplyPreviewBar extends StatelessWidget {
  const ReplyPreviewBar({
    super.key,
    required this.replyTo,
    required this.onCancel,
  });

  final ChatMessage replyTo;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
      decoration: const BoxDecoration(
        color: DSColor.card,
        border: Border(top: BorderSide(color: DSColor.onSurface08, width: 0.5)),
      ),
      child: Row(
        children: <Widget>[
          Container(width: 3, height: 34, color: DSColor.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  replyTo.isMine
                      ? context.l10N.chat_reply_self
                      : context.l10N.chat_reply_other,
                  style: const TextStyle(
                    fontFamily: dsFontFamily,
                    fontSize: DSFontSize.bodySmall,
                    fontWeight: DSFontWeight.semiBold,
                    color: DSColor.primary,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  replyTo.text ?? context.l10N.chat_media_placeholder,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: dsFontFamily,
                    fontSize: DSFontSize.bodyMedium,
                    color: DSColor.onSurface45,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onCancel,
            icon: const Icon(Icons.close, color: DSColor.onSurface45, size: 20),
            splashRadius: 18,
          ),
        ],
      ),
    );
  }
}
