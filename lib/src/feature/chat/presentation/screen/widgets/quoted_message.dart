import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_message.dart';

/// Compact reply-preview strip rendered inside a bubble above the body.
///
/// Mirrors the design's quoted-message chip: a thin accent bar on the left and
/// a single-line snippet of the message being replied to. Colours flip with
/// [mine] so the chip reads against both the gold (me) and dark (them) bubbles.
class QuotedMessage extends StatelessWidget {
  const QuotedMessage({super.key, required this.reply, required this.mine});

  final ChatMessage reply;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final Color barColor = mine ? Colors.black26 : DSColor.primary;
    final Color background = mine
        ? Colors.black.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.06);
    final Color textColor = mine
        ? Colors.black.withValues(alpha: 0.70)
        : Colors.white.withValues(alpha: 0.70);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            width: 3,
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              reply.text ?? '[media]',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: dsFontFamily,
                fontSize: 12,
                fontWeight: DSFontWeight.medium,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
