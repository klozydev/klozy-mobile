import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_message.dart';

/// A file-attachment bubble: a tappable tile with a document icon and the
/// attachment name. Tail corner flips with [ChatMessage.isMine].
class FileMessage extends StatelessWidget {
  const FileMessage({super.key, required this.message, this.onOpen});

  final ChatMessage message;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final bool mine = message.isMine;
    final double maxWidth = MediaQuery.sizeOf(context).width * 0.8;
    final Color foreground = mine ? Colors.black : Colors.white;
    final String name = message.firstMedia?.name ?? 'Attachment';

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: GestureDetector(
        onTap: onOpen,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
          decoration: BoxDecoration(
            color: mine ? DSColor.primary : DSColor.card,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(mine ? 16 : 5),
              bottomRight: Radius.circular(mine ? 5 : 16),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: mine
                      ? Colors.black.withValues(alpha: 0.12)
                      : Colors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  Icons.insert_drive_file_outlined,
                  size: 18,
                  color: foreground,
                ),
              ),
              const SizedBox(width: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 160),
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: dsFontFamily,
                    fontSize: 13,
                    fontWeight: DSFontWeight.semiBold,
                    color: foreground,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
