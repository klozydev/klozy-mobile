import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_message.dart';

/// Centered system/event line (e.g. "You started a conversation").
///
/// Small muted grey text, centered in the thread between message groups.
class EventMessage extends StatelessWidget {
  const EventMessage({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Center(
        child: Text(
          message.text ?? '',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: dsFontFamily,
            fontSize: 11,
            fontWeight: DSFontWeight.medium,
            color: DSColor.onSurface35,
          ),
        ),
      ),
    );
  }
}
