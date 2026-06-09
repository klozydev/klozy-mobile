import 'dart:async';

import 'package:share_plus/share_plus.dart';

/// Thin wrapper over the system share sheet.
class AppShare {
  const AppShare._();

  /// Opens the OS share sheet with [value]. Fire-and-forget.
  static void text(String value) {
    unawaited(SharePlus.instance.share(ShareParams(text: value)));
  }

  static void reel(String reelId, {String? caption}) {
    final link = 'https://klozy.app/reels/$reelId';
    text(caption == null || caption.isEmpty ? link : '$caption\n$link');
  }

  static void product(String productId, {String? title}) {
    final link = 'https://klozy.app/products/$productId';
    text(title == null || title.isEmpty ? link : '$title\n$link');
  }
}
