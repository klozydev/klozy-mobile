import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:klozy/src/feature/chat/domain/usecase/open_or_create_thread.dart';
import 'package:klozy/src/router/app_router.dart';

/// Single entry point every "message this user" affordance routes through.
///
/// Conversations are keyed by backend user ids, so the conversation id is
/// computed locally (`sorted(myId, otherUserId)`) and the thread opens
/// **instantly** — the doc is created/refreshed in the background. The header
/// renders from the passed [displayName] / [avatarUrl] hints meanwhile.
class ChatEntry {
  const ChatEntry._();

  static Future<void> open(
    BuildContext context, {
    required String otherUserId,
    String? displayName,
    String? avatarUrl,
  }) async {
    // My backend id from the cached profile (warm after bootstrap → no network).
    final String myId = (await locator<MeRepository>().getMe()).id;
    if (otherUserId.isEmpty || otherUserId == myId || !context.mounted) return;

    final List<String> ids = <String>[myId, otherUserId]..sort();
    final String conversationId = '${ids.first}_${ids[1]}';

    // Ensure the conversation doc exists BEFORE opening the thread. The thread
    // page immediately subscribes to the messages subcollection; if the parent
    // conversation doc doesn't exist yet, that listen is denied by the security
    // rule and the (un-retried) stream stays dead for the session — so the
    // first message's optimistic bubble is never reconciled with its server
    // echo and spins on "sending" forever (until the chat is reopened). Awaiting
    // creation here closes that race. It's a no-op round-trip for existing
    // threads, and we still navigate even if creation fails so chat never traps.
    try {
      await locator<OpenOrCreateThread>().call(
        otherUserId,
        displayName: displayName,
        avatarUrl: avatarUrl,
      );
    } catch (_) {
      // Best-effort — the first send also upserts the conversation doc.
    }
    if (!context.mounted) return;

    await context.router.push(
      ChatThreadRoute(
        conversationId: conversationId,
        otherName: displayName,
        otherAvatarUrl: avatarUrl,
      ),
    );
  }
}
