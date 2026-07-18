import 'package:flutter/foundation.dart';

/// Guards the app against duplicate navigation.
///
/// A navigation-triggering action can fire more than once before its
/// destination route is on screen — a rapid double-tap, or an async "launcher"
/// flow re-triggered while it is still resolving. Both stack duplicate routes.
///
/// Two complementary mechanisms cover both cases:
///
/// * [shouldNavigate] — a short per-target cooldown for *direct* route pushes.
///   The `pushSafe`/`replaceSafe`/`replaceAllSafe` extensions drop a second
///   identical navigation fired within [_cooldown]. The target's identity
///   includes its arguments (see `PageRouteInfo` equality), so navigating to a
///   *different* item of the same route type is never blocked.
///
/// * [runExclusive] — an in-flight lock for launcher flows that do async work
///   (network, cache) *before* navigating (e.g. opening a chat thread). A
///   second trigger with the same key is ignored while the first is still
///   running — which a time cooldown alone cannot guarantee once the work
///   outlasts the window.
///
/// Single instance, no dependencies: reached via [NavigationGuard.instance].
class NavigationGuard {
  NavigationGuard._();

  /// The app-wide guard. All navigation shares this single state.
  static final NavigationGuard instance = NavigationGuard._();

  /// Long enough to absorb an accidental double/triple-tap (~100-300ms), short
  /// enough never to block a deliberate re-navigation after returning to a
  /// screen.
  static const Duration _cooldown = Duration(milliseconds: 500);

  final Map<Object, DateTime> _recent = <Object, DateTime>{};
  final Set<Object> _inFlight = <Object>{};

  /// Returns `true` if a navigation identified by [key] may proceed, `false`
  /// if an identical one occurred within [_cooldown]. Records the timestamp
  /// when it proceeds.
  bool shouldNavigate(Object key) {
    final DateTime now = DateTime.now();
    _recent.removeWhere(
      (Object _, DateTime at) => now.difference(at) >= _cooldown,
    );
    if (_recent.containsKey(key)) {
      return false;
    }
    _recent[key] = now;
    return true;
  }

  /// Runs [action] unless another call with the same [key] is still in flight,
  /// in which case it is ignored. The lock is held for the whole [action],
  /// including any navigation performed at its end.
  Future<void> runExclusive(Object key, Future<void> Function() action) async {
    if (_inFlight.contains(key)) {
      return;
    }
    _inFlight.add(key);
    try {
      await action();
    } finally {
      _inFlight.remove(key);
    }
  }

  @visibleForTesting
  void reset() {
    _recent.clear();
    _inFlight.clear();
  }
}
