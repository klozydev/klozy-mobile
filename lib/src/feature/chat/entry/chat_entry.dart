import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:klozy/src/router/app_router.dart';
import 'package:kosmos_chat/backend/provider/message_list.dart';
import 'package:kosmos_chat/kosmos_chat.dart';

/// Single entry point every "message this user" affordance routes through.
/// Finds or creates the 1:1 tchat with [otherUserId], then opens the thread.
class ChatEntry {
  const ChatEntry._();

  static bool _busy = false;

  static Future<void> open(
    BuildContext context, {
    required String otherUserId,
  }) async {
    final me = FirebaseAuth.instance.currentUser?.uid;
    if (me == null || _busy) return;
    _busy = true;
    final String? tchatId;
    // _busy only guards the find-or-create section: router.push resolves when
    // the pushed thread is POPPED, so holding the flag across it would
    // silently swallow every openChatWith from screens stacked on a thread.
    try {
      const controller = TchatController();
      final existing = await controller.tchatExist(
        TchatType.oneToOne,
        userId: me,
        otherUserId: otherUserId,
      );
      tchatId =
          existing?.id ??
          await controller.createTchat(
            TchatType.oneToOne,
            userId1: me,
            userId2: otherUserId,
          );
    } finally {
      _busy = false;
    }
    if (tchatId == null || !context.mounted) return;
    // Prime the message provider from the root ProviderScope container.
    ProviderScope.containerOf(
      context,
      listen: false,
    ).read(messageListProvider).init(tchatId);
    if (!context.mounted) return;
    await context.router.push(ChatThreadRoute(tchatId: tchatId));
  }
}
