import 'dart:async';

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

    // Open immediately; ensure the conversation doc exists in the background.
    unawaited(
      locator<OpenOrCreateThread>().call(
        otherUserId,
        displayName: displayName,
        avatarUrl: avatarUrl,
      ),
    );

    await context.router.push(
      ChatThreadRoute(
        conversationId: conversationId,
        otherName: displayName,
        otherAvatarUrl: avatarUrl,
      ),
    );
  }
}
