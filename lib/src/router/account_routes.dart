/// Route-gating contract for guest browsing (EPIC 0).
///
/// Guest browsing is OPEN: the shell, feed, product detail and search must be
/// reachable WITHOUT an account. Gating happens at the ACTION (wishlist, follow,
/// sell) via the account-gate helper, NOT at these browse routes.
///
/// This file is the single source of truth for which route paths require a
/// resolved account ([AccountGuard]) versus which are guest-allowed. The actual
/// guard wiring in `app_router.dart` must be kept in lockstep with these lists.
abstract final class AccountRoutes {
  /// Paths reachable by a guest (no account). These lose `_authGuard` and gain
  /// NO guard (browse is fully open).
  static const Set<String> guestAllowed = <String>{
    '/', // shell
    'home', // shell tab
    'search', // shell tab
    '/product/:id',
    '/users/:id',
    '/reel/:id',
  };

  /// Paths that require a resolved valid account — guarded by [AccountGuard].
  /// (Previously `_authGuard`; the swap is documented in the launch plan.)
  static const Set<String> private = <String>{
    'chat', // shell tab
    'profile', // shell tab
    '/cart',
    '/checkout',
    '/orders',
    '/orders/:id',
    '/chat/:conversationId',
    '/sell',
    '/product/:id/edit',
    '/seller-role',
    '/offers',
    '/notifications',
    '/users/:id/connections',
    '/reel-composer',
    '/settings',
    '/settings/edit-profile',
    '/settings/addresses',
    '/settings/addresses/form',
    '/settings/payouts',
    '/settings/preferences',
    '/settings/payout',
    '/settings/seller-stats',
    '/settings/seller-verification',
    '/settings/blocked',
    '/settings/legal/:key',
  };

  /// Onboarding-resume routes — reachable by [AccountStatus.incompleteOnboarding]
  /// and [AccountStatus.valid], but not guest/legacy.
  static const Set<String> onboarding = <String>{
    '/onboarding/personalize',
    '/onboarding/profile',
  };
}
