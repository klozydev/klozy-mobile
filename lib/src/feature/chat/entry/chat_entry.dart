import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/social/social_repository.dart';
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
    Map<String, dynamic>? metadata,
  }) async {
    final me = FirebaseAuth.instance.currentUser?.uid;
    if (me == null || _busy) return;
    _busy = true;
    try {
      // Callers pass the backend user id, but the kosmos chat keys threads by
      // Firebase UID (that's what `me` is). Resolve the other user's Firebase
      // UID so both participants — and the backend's offer/purchase mirror —
      // build the same thread id.
      String other = otherUserId;
      try {
        final profile = await locator<SocialRepository>().getProfile(
          otherUserId,
        );
        if (profile.firebaseUid.isNotEmpty) other = profile.firebaseUid;
      } catch (_) {}
      const controller = TchatController();
      final existing = await controller.tchatExist(
        TchatType.oneToOne,
        userId: me,
        otherUserId: other,
      );
      final tchatId =
          existing?.id ??
          await controller.createTchat(
            TchatType.oneToOne,
            userId1: me,
            userId2: other,
          );
      if (tchatId == null || !context.mounted) return;
      // Prime the message provider from the root ProviderScope container.
      ProviderScope.containerOf(
        context,
        listen: false,
      ).read(messageListProvider).init(tchatId);
      if (!context.mounted) return;
      await context.router.push(ChatThreadRoute(tchatId: tchatId));
    } finally {
      _busy = false;
    }
  }
}
