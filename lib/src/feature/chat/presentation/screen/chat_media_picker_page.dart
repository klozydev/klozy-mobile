import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:kosmos_chat/kosmos_chat.dart';

/// Media preview/send page for a thread (`/chat/:tchatId/picker`).
///
/// Hosts the package's [MediaPreviewerSpecialPage], reached from the message
/// composer after the user picks media to send.
@RoutePage()
class ChatMediaPickerPage extends StatelessWidget {
  final String tchatId;

  const ChatMediaPickerPage({
    @PathParam('tchatId') required this.tchatId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColor.surface,
      body: MediaPreviewerSpecialPage(tchatId: tchatId),
    );
  }
}
