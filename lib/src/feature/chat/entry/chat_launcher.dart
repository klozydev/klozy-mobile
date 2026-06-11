import 'package:flutter/widgets.dart';

import 'package:klozy/src/feature/chat/entry/chat_entry.dart';

/// Ergonomic entry point for feature widgets: `context.openChatWith(userId)`.
/// All "message this user" affordances (profile, product, order, cart) use this.
extension ChatLauncher on BuildContext {
  Future<void> openChatWith(String otherUserId) =>
      ChatEntry.open(this, otherUserId: otherUserId);
}
