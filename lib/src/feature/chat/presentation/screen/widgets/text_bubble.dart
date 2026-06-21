import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_message.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/quoted_message.dart';

/// A plain text chat bubble, constrained to 80% of the screen width.
///
/// "Me" bubbles are gold with black text and a clipped bottom-right corner;
/// "them" bubbles are dark with white text and a clipped bottom-left corner.
/// When [ChatMessage.replyTo] is set, a [QuotedMessage] preview is stacked
/// above the body inside the same bubble.
class TextBubble extends StatelessWidget {
  const TextBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final bool mine = message.isMine;
    final double maxWidth = MediaQuery.sizeOf(context).width * 0.8;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: mine ? DSColor.primary : DSColor.card,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(mine ? 18 : 5),
            bottomRight: Radius.circular(mine ? 5 : 18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (message.replyTo != null) ...<Widget>[
              QuotedMessage(reply: message.replyTo!, mine: mine),
              const SizedBox(height: 6),
            ],
            Text(
              message.text ?? '',
              softWrap: true,
              style: TextStyle(
                fontFamily: dsFontFamily,
                fontSize: 14,
                fontWeight: DSFontWeight.medium,
                height: 19 / 14,
                color: mine ? Colors.black : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
