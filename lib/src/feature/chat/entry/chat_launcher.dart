import 'package:flutter/widgets.dart';

import 'package:klozy/src/feature/chat/entry/chat_entry.dart';

/// Ergonomic entry point for feature widgets: `context.openChatWith(userId)`.
/// All "message this user" affordances (profile, product, order, cart) use this.
///
/// Pass [displayName] / [avatarUrl] (callers already show them) so the thread
/// header renders instantly while the conversation doc is ensured.
extension ChatLauncher on BuildContext {
  Future<void> openChatWith(
    String otherUserId, {
    String? displayName,
    String? avatarUrl,
  }) => ChatEntry.open(
    this,
    otherUserId: otherUserId,
    displayName: displayName,
    avatarUrl: avatarUrl,
  );
}
