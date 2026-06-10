import 'package:injectable/injectable.dart';
import 'package:klozy/src/domain/account/entity/account_status.dart';
import 'package:klozy/src/domain/account/usecase/get_account_status_usecase.dart';

/// Action-gating counterpart to [GetAccountStatusUseCase]. Call-sites that gate
/// an action (wishlist toggle, follow, sell entry) use this to decide whether to
/// proceed or to prompt sign-up.
///
/// Returns the resolved [AccountStatus] so the caller can branch the prompt
/// copy (guest → "create an account", legacy → "finish setting up", etc.).
/// A convenience [isValid] is provided for the common allow/deny check.
@injectable
class RequireValidAccountUseCase {
  final GetAccountStatusUseCase _getAccountStatus;

  RequireValidAccountUseCase(this._getAccountStatus);

  Future<AccountStatus> call() => _getAccountStatus();

  Future<bool> isValid() async => (await call()) == AccountStatus.valid;
}
