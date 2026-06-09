import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';

/// Placeholder for the Chat tab (chat list · 1:1 thread). Built next.
@RoutePage()
class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColor.surface,
      body: Center(
        child: Text(
          context.l10N.chat_title,
          style: context.textTheme.headlineLarge,
        ),
      ),
    );
  }
}
