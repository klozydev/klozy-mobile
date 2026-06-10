import 'package:auto_route/auto_route.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/domain/account/entity/account_status.dart';
import 'package:klozy/src/domain/account/usecase/get_account_status_usecase.dart';
import 'package:klozy/src/domain/auth/auth_repository.dart';
import 'package:klozy/src/router/app_router.dart';

/// Replaces [AuthGuard] on private routes (see [AccountRoutes.private]). Resolves
/// the full [AccountStatus] rather than a bare `currentUser != null` check, so
/// routing can branch on the four states:
///
/// - guest → redirect to WelcomeRoute (no sign-out needed; no session to clean).
/// - legacy → sign out (stale Firebase session), then redirect to WelcomeRoute.
/// - incompleteOnboarding → resume onboarding at PersonalizeRoute.
/// - valid → `resolver.next(true)`.
///
/// Guest-allowed browse routes ([AccountRoutes.guestAllowed]) must NOT use this
/// guard at all.
@injectable
class AccountGuard extends AutoRouteGuard {
  final GetAccountStatusUseCase _getAccountStatus;
  final AuthRepository _authRepository;

  AccountGuard(this._getAccountStatus, this._authRepository);

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    // Guard against settling the resolver twice (once in the happy path, once
    // in the catch-all error handler).
    var settled = false;

    void settle(void Function() action) {
      if (settled) return;
      settled = true;
      action();
    }

    _getAccountStatus()
        .then((AccountStatus status) {
          switch (status) {
            case AccountStatus.valid:
              settle(() => resolver.next(true));
            case AccountStatus.incompleteOnboarding:
              settle(() => resolver.redirectUntil(const PersonalizeRoute()));
            case AccountStatus.legacy:
              // Settle the resolver FIRST so navigation is never left hanging,
              // then clean up the stale session fire-and-forget. If signOut
              // fails the user is still redirected to Welcome; the next guard
              // check will re-evaluate the session.
              settle(() => resolver.redirectUntil(const WelcomeRoute()));
              _authRepository.signOut().ignore();
            case AccountStatus.guest:
              settle(() => resolver.redirectUntil(const WelcomeRoute()));
          }
        })
        .catchError((_) {
          // Any exception from _getAccountStatus or the then-callback must
          // still settle the resolver, otherwise navigation hangs silently.
          settle(() => resolver.next(false));
        });
  }
}
