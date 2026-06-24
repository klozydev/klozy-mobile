import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_message.dart';
import 'package:klozy/src/feature/chat/domain/entity/message_kind.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/audio_message.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/event_message.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/file_message.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/image_video_message.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/offer_card.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/purchase_pill.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/text_bubble.dart';

/// One message row: aligns the bubble (mine → right, them → left, system →
/// centered), renders the timestamp underneath, and enables swipe-to-reply.
class MessageRow extends StatelessWidget {
  const MessageRow({
    super.key,
    required this.message,
    required this.onReply,
    required this.onOpenMedia,
    required this.onAcceptOffer,
    required this.onRefuseOffer,
    this.onQuotedTap,
  });

  final ChatMessage message;
  final ValueChanged<ChatMessage> onReply;
  final ValueChanged<ChatMessage> onOpenMedia;
  final ValueChanged<ChatMessage> onAcceptOffer;
  final ValueChanged<ChatMessage> onRefuseOffer;

  /// Called with a message id when a quoted reply is tapped (jump-to-message).
  final ValueChanged<String>? onQuotedTap;

  bool get _isCentered =>
      message.kind == ChatMessageKind.purchase ||
      message.kind == ChatMessageKind.event ||
      message.kind == ChatMessageKind.deleted;

  bool get _canReply => !_isCentered;

  @override
  Widget build(BuildContext context) {
    final CrossAxisAlignment align = _isCentered
        ? CrossAxisAlignment.center
        : (message.isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start);
    final Alignment rowAlign = _isCentered
        ? Alignment.center
        : (message.isMine ? Alignment.centerRight : Alignment.centerLeft);

    final Widget content = Column(
      crossAxisAlignment: align,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _bubble(),
        Padding(
          padding: EdgeInsets.only(
            top: 3,
            right: !_isCentered && message.isMine ? 4 : 0,
            left: !_isCentered && !message.isMine ? 4 : 0,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                message.timeLabel,
                style: const TextStyle(
                  fontFamily: dsFontFamily,
                  fontSize: 10,
                  color: DSColor.onSurface35,
                ),
              ),
              if (message.isMine && message.isSending) ...<Widget>[
                const SizedBox(width: 4),
                const SizedBox(
                  width: 9,
                  height: 9,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.4,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      DSColor.onSurface45,
                    ),
                  ),
                ),
              ] else if (message.isMine && message.isFailed) ...<Widget>[
                const SizedBox(width: 4),
                const Icon(
                  Icons.error_outline,
                  size: 11,
                  color: DSColor.danger,
                ),
              ],
            ],
          ),
        ),
      ],
    );

    // Align fills the full row width so the swipe-to-reply gesture is
    // recognised anywhere on the row, not just on the (shrink-wrapped) bubble.
    Widget row = Align(alignment: rowAlign, child: content);

    if (_canReply) {
      row = Dismissible(
        key: ValueKey<String>('reply_${message.id}'),
        direction: DismissDirection.startToEnd,
        dismissThresholds: const <DismissDirection, double>{
          DismissDirection.startToEnd: 0.25,
        },
        confirmDismiss: (_) async {
          onReply(message);
          return false;
        },
        background: const _ReplyHint(),
        child: row,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: row,
    );
  }

  Widget _bubble() {
    switch (message.kind) {
      case ChatMessageKind.text:
        return TextBubble(message: message, onQuotedTap: onQuotedTap);
      case ChatMessageKind.image:
      case ChatMessageKind.video:
        return ImageVideoMessage(
          message: message,
          onOpen: () => onOpenMedia(message),
        );
      case ChatMessageKind.audio:
        return AudioMessage(message: message);
      case ChatMessageKind.file:
        return FileMessage(message: message);
      case ChatMessageKind.offer:
        return OfferCard(
          message: message,
          onAccept: () => onAcceptOffer(message),
          onRefuse: () => onRefuseOffer(message),
        );
      case ChatMessageKind.purchase:
        return PurchasePill(message: message);
      case ChatMessageKind.event:
        return EventMessage(message: message);
      case ChatMessageKind.deleted:
        return const _DeletedBubble();
    }
  }
}

class _ReplyHint extends StatelessWidget {
  const _ReplyHint();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(left: 12),
        child: Icon(Icons.reply, color: DSColor.onSurface35, size: 20),
      ),
    );
  }
}

class _DeletedBubble extends StatelessWidget {
  const _DeletedBubble();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        context.l10N.chat_message_deleted,
        style: const TextStyle(
          fontFamily: dsFontFamily,
          fontSize: DSFontSize.bodySmall,
          fontStyle: FontStyle.italic,
          color: DSColor.onSurface35,
        ),
      ),
    );
  }
}
