import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/router/app_router.dart';

/// Blocks the authenticated shell when there is no Firebase user, redirecting to
/// the Welcome flow.
@injectable
class AuthGuard extends AutoRouteGuard {
  final FirebaseAuth _firebaseAuth;

  AuthGuard(this._firebaseAuth);

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    if (_firebaseAuth.currentUser != null) {
      resolver.next(true);
    } else {
      resolver.redirectUntil(const WelcomeRoute());
    }
  }
}
