import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/core/account/account_gate_sheet.dart';
import 'package:klozy/src/domain/account/entity/account_status.dart';
import 'package:klozy/src/domain/account/usecase/require_valid_account_usecase.dart';

/// Presentation-layer helper that gates an ACTION (not a route) behind a valid
/// account — the EPIC 0 guest-browsing model. Call-sites (wishlist toggle,
/// follow button, sell FAB) wrap their action in [guard]:
///
/// ```dart
/// locator<AccountGate>().guard(
///   context,
///   onAllowed: () => bloc.add(WishlistToggled(id)),
/// );
/// ```
///
/// When the account is not valid it presents the login/sign-up CTA bottom-sheet
/// ([AccountGateSheet]) instead of running [onAllowed].
@injectable
class AccountGate {
  final RequireValidAccountUseCase _requireValidAccount;

  AccountGate(this._requireValidAccount);

  /// Runs [onAllowed] when the account is [AccountStatus.valid]; otherwise shows
  /// the sign-up prompt. [onBlocked] (optional) lets the caller react to the
  /// blocked status (e.g. to keep an optimistic toggle from flipping).
  Future<void> guard(
    BuildContext context, {
    required FutureOr<void> Function() onAllowed,
    FutureOr<void> Function()? onBlocked,
  }) async {
    final status = await _requireValidAccount();
    if (status == AccountStatus.valid) {
      await onAllowed();
    } else {
      await AccountGateSheet.show(context, status: status);
      await onBlocked?.call();
    }
  }
}
