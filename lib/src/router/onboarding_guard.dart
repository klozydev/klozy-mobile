import 'package:auto_route/auto_route.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/domain/account/entity/account_status.dart';
import 'package:klozy/src/domain/account/usecase/get_account_status_usecase.dart';
import 'package:klozy/src/domain/auth/auth_repository.dart';
import 'package:klozy/src/router/app_router.dart';

/// Guard for the onboarding-resume routes (PersonalizeRoute,
/// ProfileCompletionRoute — see [AccountRoutes.onboarding]).
///
/// Unlike [AccountGuard], this guard lets [AccountStatus.incompleteOnboarding]
/// PROCEED (`next(true)`) instead of redirecting it to PersonalizeRoute — using
/// AccountGuard here causes an infinite redirect loop (the guard would redirect
/// the onboarding route back to itself). Only guest/legacy are bounced.
///
/// - valid → proceed (e.g. revisiting onboarding from settings).
/// - incompleteOnboarding → proceed (this is exactly who onboarding is for).
/// - guest → redirect to WelcomeRoute.
/// - legacy → redirect to WelcomeRoute, then sign out the stale session.
@injectable
class OnboardingGuard extends AutoRouteGuard {
  final GetAccountStatusUseCase _getAccountStatus;
  final AuthRepository _authRepository;

  OnboardingGuard(this._getAccountStatus, this._authRepository);

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
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
            case AccountStatus.incompleteOnboarding:
              settle(() => resolver.next(true));
            case AccountStatus.legacy:
              settle(() => resolver.redirectUntil(const WelcomeRoute()));
              _authRepository.signOut().ignore();
            case AccountStatus.guest:
              settle(() => resolver.redirectUntil(const WelcomeRoute()));
          }
        })
        .catchError((_) {
          // Settle even on failure so navigation never hangs.
          settle(() => resolver.next(false));
        });
  }
}
