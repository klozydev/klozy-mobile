import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:kosmos_chat/kosmos_chat.dart';

/// A single 1:1 conversation thread (`/chat/:tchatId`).
///
/// Hosts the package's [TchatMessagePage]; the route param feeds its tchatId.
@RoutePage()
class ChatThreadPage extends StatelessWidget {
  final String tchatId;

  const ChatThreadPage({
    @PathParam('tchatId') required this.tchatId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColor.surface,
      body: SafeArea(child: TchatMessagePage(tchatId: tchatId)),
    );
  }
}
