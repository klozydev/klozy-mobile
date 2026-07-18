import 'package:auto_route/auto_route.dart';

import 'package:klozy/src/core/navigation/navigation_guard.dart';

/// Duplicate-proof navigation. Prefer these over the raw `push`/`replace`/
/// `replaceAll` everywhere a user action triggers navigation: a rapid
/// double-tap on the trigger then opens the destination only once.
///
/// Each call is deduplicated by its target route (route name + arguments) via
/// [NavigationGuard], so tapping the same card twice is a no-op while
/// navigating to a different item is unaffected.
///
/// For flows that do async work before navigating, use
/// [NavigationGuard.runExclusive] around the whole flow instead — the cooldown
/// here cannot span work that outlasts it.
extension SafeNavigation on StackRouter {
  /// [push], ignored when the same route was pushed within the guard cooldown.
  Future<T?> pushSafe<T extends Object?>(
    PageRouteInfo<dynamic> route, {
    OnNavigationFailure? onFailure,
  }) {
    if (!NavigationGuard.instance.shouldNavigate(route)) {
      return Future<T?>.value();
    }
    return push<T>(route, onFailure: onFailure);
  }

  /// [replace], ignored when the same route was replaced within the cooldown.
  Future<T?> replaceSafe<T extends Object?>(
    PageRouteInfo<dynamic> route, {
    OnNavigationFailure? onFailure,
  }) {
    if (!NavigationGuard.instance.shouldNavigate(route)) {
      return Future<T?>.value();
    }
    return replace<T>(route, onFailure: onFailure);
  }

  /// [replaceAll], ignored when the same stack was requested within the
  /// cooldown. Keyed by the ordered route names.
  Future<void> replaceAllSafe(
    List<PageRouteInfo<dynamic>> routes, {
    OnNavigationFailure? onFailure,
    bool updateExistingRoutes = true,
  }) {
    final String key =
        'replaceAll:${routes.map((PageRouteInfo<dynamic> r) => r.routeName).join(',')}';
    if (!NavigationGuard.instance.shouldNavigate(key)) {
      return Future<void>.value();
    }
    return replaceAll(
      routes,
      onFailure: onFailure,
      updateExistingRoutes: updateExistingRoutes,
    );
  }
}
