import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/app/bloc/account/account_event.dart';
import 'package:klozy/src/app/bloc/account/account_state.dart';
import 'package:klozy/src/domain/account/entity/account_status.dart';
import 'package:klozy/src/domain/account/usecase/get_account_status_usecase.dart';
import 'package:klozy/src/domain/auth/auth_repository.dart';
import 'package:klozy/src/domain/auth/entity/auth_user.dart';

/// Global session-resolution surface. Holds the current [AccountStatus] so the
/// app start (and listeners) can route once the session is classified.
///
/// Re-resolves automatically on every Firebase auth change (sign-in/sign-out),
/// so consumers like the Chat/Profile tab gates never render a stale status
/// after an in-session login or logout.
///
/// Legacy handling: if the resolved status is [AccountStatus.legacy] (Firebase
/// user exists but the Klozy backend has no usable profile, or the user is
/// anonymous), the bloc silently calls [AuthRepository.signOut] and then
/// re-resolves to [AccountStatus.guest]. This prevents the app from being
/// permanently stuck in a legacy loop on every cold start.
@injectable
class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final GetAccountStatusUseCase _getAccountStatus;
  final AuthRepository _authRepository;
  StreamSubscription<AuthUser?>? _authSubscription;

  AccountBloc(this._getAccountStatus, this._authRepository)
    : super(const AccountInitial()) {
    on<AccountBootstrapRequested>(_onBootstrapRequested);
    // Skip the immediate replay of the current auth state — the initial
    // bootstrap is dispatched explicitly at app start. Subsequent emissions
    // (sign-in, sign-out) must re-resolve the account status.
    _authSubscription = _authRepository
        .authStateChanges()
        .skip(1)
        .listen((AuthUser? _) => add(const AccountBootstrapRequested()));
  }

  Future<void> _onBootstrapRequested(
    AccountBootstrapRequested event,
    Emitter<AccountState> emit,
  ) async {
    emit(const AccountResolving());
    final status = await _getAccountStatus();
    if (status == AccountStatus.legacy) {
      // Silently clean up the stale Firebase session so the app does not loop
      // back to legacy on every restart. After sign-out the user is a clean
      // guest who can browse freely. A sign-out failure must never strand the
      // bloc in AccountResolving — the user is effectively a guest either way.
      try {
        await _authRepository.signOut();
      } catch (_) {
        // Ignored: the next bootstrap re-evaluates the session.
      }
      emit(const AccountResolved(AccountStatus.guest));
    } else {
      emit(AccountResolved(status));
    }
  }

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    return super.close();
  }
}
