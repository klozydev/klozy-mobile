import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/app/bloc/account/account_event.dart';
import 'package:klozy/src/app/bloc/account/account_state.dart';
import 'package:klozy/src/domain/account/entity/account_status.dart';
import 'package:klozy/src/domain/account/usecase/get_account_status_usecase.dart';
import 'package:klozy/src/domain/auth/auth_repository.dart';

/// Global session-resolution surface. Holds the current [AccountStatus] so the
/// app start (and listeners) can route once the session is classified.
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

  AccountBloc(this._getAccountStatus, this._authRepository)
    : super(const AccountInitial()) {
    on<AccountBootstrapRequested>(_onBootstrapRequested);
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
      // guest who can browse freely.
      await _authRepository.signOut();
      emit(const AccountResolved(AccountStatus.guest));
    } else {
      emit(AccountResolved(status));
    }
  }
}
