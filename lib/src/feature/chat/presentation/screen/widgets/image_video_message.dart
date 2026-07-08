import 'dart:io';

import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_network_image/ds_network_image.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_message.dart';
import 'package:klozy/src/feature/chat/domain/entity/message_kind.dart';

/// A media bubble for image / video messages. Renders the network image (or a
/// video poster with a play overlay), falling back to a labelled placeholder
/// when no URL is available. Tail corner flips with [ChatMessage.isMine].
class ImageVideoMessage extends StatelessWidget {
  const ImageVideoMessage({super.key, required this.message, this.onOpen});

  final ChatMessage message;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final bool mine = message.isMine;
    final double maxWidth = MediaQuery.sizeOf(context).width * 0.8;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: GestureDetector(
        onTap: onOpen,
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: BoxDecoration(
            color: DSColor.card,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 0.5,
            ),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(mine ? 16 : 5),
              bottomRight: Radius.circular(mine ? 5 : 16),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(mine ? 16 : 5),
              bottomRight: Radius.circular(mine ? 5 : 16),
            ),
            child: Stack(
              children: <Widget>[
                _content(context),
                if (message.isSending)
                  Positioned.fill(
                    child: ColoredBox(
                      color: Colors.black.withValues(alpha: 0.32),
                      child: const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              DSColor.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    final String? url = message.firstMedia?.url;
    final String? localPath = message.firstMedia?.localPath;

    if (message.kind == ChatMessageKind.image) {
      if (url != null) {
        return DSNetworkImage(
          imageUrl: url,
          width: 208,
          fit: BoxFit.cover,
          borderRadius: DSBorderRadius.none,
          fallback: _imagePlaceholder(),
        );
      }
      if (localPath != null) {
        return Image.file(
          File(localPath),
          width: 208,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _imagePlaceholder(),
        );
      }
    }

    if (message.kind == ChatMessageKind.video) {
      return _videoPoster();
    }

    return _labelPlaceholder(context);
  }

  Widget _imagePlaceholder() {
    return Container(width: 208, height: 150, color: DSColor.cardInset);
  }

  Widget _videoPoster() {
    final String? thumbnailUrl = message.firstMedia?.thumbnailUrl;

    return SizedBox(
      width: 208,
      height: 150,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (thumbnailUrl != null)
            DSNetworkImage(
              imageUrl: thumbnailUrl,
              width: 208,
              height: 150,
              fit: BoxFit.cover,
              borderRadius: DSBorderRadius.none,
              fallback: _videoBackground(),
            )
          else
            _videoBackground(),
          Center(
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.42),
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _videoBackground() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF181818), Color(0xFF000000)],
        ),
      ),
    );
  }

  Widget _labelPlaceholder(BuildContext context) {
    return Container(
      width: 180,
      height: 138,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF181818), Color(0xFF0E0E0E)],
        ),
      ),
      child: Text(
        message.firstMedia?.name ?? context.l10N.chat_media_photo,
        style: TextStyle(
          fontFamily: dsFontFamily,
          fontSize: 10,
          fontWeight: DSFontWeight.medium,
          color: Colors.white.withValues(alpha: 0.40),
        ),
      ),
    );
  }
}
