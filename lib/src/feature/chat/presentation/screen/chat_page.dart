import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:kosmos_chat/kosmos_chat.dart';

/// The Chat tab (shell index 2): hosts the package's conversation list.
///
/// The root [ProviderScope] (in App) supplies the Riverpod scope the package
/// widgets need; navigation into a thread is driven by MobileTchatController.
@RoutePage()
class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: DSColor.surface,
      body: SafeArea(child: TchatListPage()),
    );
  }
}
