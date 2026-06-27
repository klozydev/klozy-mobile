import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Single arbiter guaranteeing that only one reel player has audio at a time.
///
/// Every [ReelPageWidget] state registers itself as the [token] when it wants
/// to play, supplying a [pauseSelf] callback. The coordinator preempts whoever
/// was playing before — pausing it — so two surfaces (the Home reels viewer and
/// the full-screen [SingleReelPage]) can never overlap their audio while one is
/// pushed over the other.
///
/// It does not own the [VideoPlayerController]s: each widget keeps and disposes
/// its own. The coordinator only arbitrates play/pause ownership.
@lazySingleton
class ReelPlaybackCoordinator {
  Object? _activeToken;
  VoidCallback? _activePause;

  /// Requests playback for [token]. If a different token was playing, it is
  /// preempted (paused) before [token] becomes the sole active owner.
  void requestPlayback(Object token, VoidCallback pauseSelf) {
    if (identical(_activeToken, token)) {
      _activePause = pauseSelf;
      return;
    }
    _activePause?.call();
    _activeToken = token;
    _activePause = pauseSelf;
  }

  /// Releases [token] if it currently owns playback (manual pause, off-screen,
  /// or dispose). No-op when [token] is not the active owner.
  void release(Object token) {
    if (identical(_activeToken, token)) {
      _activeToken = null;
      _activePause = null;
    }
  }

  /// True when [token] currently owns playback.
  bool isActive(Object token) => identical(_activeToken, token);
}
