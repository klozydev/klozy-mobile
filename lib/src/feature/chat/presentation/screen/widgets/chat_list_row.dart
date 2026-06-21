import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_thread.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/chat_avatar.dart';

/// A single conversation row in the messages list. All data comes from the
/// thread doc (no per-row fetch), so the whole list paints in one frame.
class ChatListRow extends StatelessWidget {
  const ChatListRow({super.key, required this.thread, required this.onTap});

  final ChatThread thread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool unread = thread.hasUnread;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 11),
        child: Row(
          children: <Widget>[
            ChatAvatar(
              initial: thread.other.initial,
              seed: thread.other.id,
              avatarUrl: thread.other.avatarUrl,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          thread.other.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: dsFontFamily,
                            fontSize: DSFontSize.bodyLarge,
                            fontWeight: unread
                                ? DSFontWeight.bold
                                : DSFontWeight.semiBold,
                            color: DSColor.onSurface,
                          ),
                        ),
                      ),
                      if (thread.other.isPro) ...<Widget>[
                        const SizedBox(width: 6),
                        const _ProChip(),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _preview(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: dsFontFamily,
                      fontSize: DSFontSize.bodyMedium,
                      fontWeight: unread
                          ? DSFontWeight.medium
                          : DSFontWeight.regular,
                      color: unread ? DSColor.onSurface75 : DSColor.onSurface45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  thread.timeLabel,
                  style: const TextStyle(
                    fontFamily: dsFontFamily,
                    fontSize: DSFontSize.bodySmall,
                    color: DSColor.onSurface35,
                  ),
                ),
                const SizedBox(height: 6),
                if (unread)
                  Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: DSColor.primary,
                      shape: BoxShape.circle,
                    ),
                  )
                else
                  const SizedBox(height: 9),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Localized one-line preview of the last message.
  String _preview(BuildContext context) {
    if (!thread.hasLastMessage) return context.l10N.chat_no_messages;
    final bool mine = thread.lastMessageFromMe;
    switch (thread.lastMessageType) {
      case 'text':
        return '${mine ? context.l10N.chat_preview_you_prefix : ''}'
            '${thread.lastMessageText ?? ''}';
      case 'media':
        return context.l10N.chat_preview_photo;
      case 'audio':
        return context.l10N.chat_preview_voice;
      case 'offer':
        return mine
            ? context.l10N.chat_preview_offer_sent
            : context.l10N.chat_preview_offer_new;
      case 'purchase':
        return '✓ ${context.l10N.chat_purchase_confirmed}';
      default:
        return thread.lastMessageText ?? '';
    }
  }
}

class _ProChip extends StatelessWidget {
  const _ProChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: DSColor.brandGlow,
        borderRadius: BorderRadius.circular(DSBorderRadius.chip),
      ),
      child: const Text(
        'PRO',
        style: TextStyle(
          fontFamily: dsFontFamily,
          fontSize: 8,
          fontWeight: DSFontWeight.bold,
          color: DSColor.primary,
        ),
      ),
    );
  }
}
