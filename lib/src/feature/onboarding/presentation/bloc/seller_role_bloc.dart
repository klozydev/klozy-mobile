import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:klozy/src/feature/onboarding/presentation/bloc/seller_role_event.dart';
import 'package:klozy/src/feature/onboarding/presentation/bloc/seller_role_failure_reason.dart';
import 'package:klozy/src/feature/onboarding/presentation/bloc/seller_role_state.dart';

@injectable
class SellerRoleBloc extends Bloc<SellerRoleEvent, SellerRoleState> {
  final MeRepository _meRepository;

  SellerRoleBloc(this._meRepository) : super(const SellerRoleIdle()) {
    on<SellerRoleSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    SellerRoleSubmitted event,
    Emitter<SellerRoleState> emit,
  ) async {
    emit(const SellerRoleSubmitting());
    try {
      await _meRepository.setSellerRole(role: event.role, iban: event.iban);
      emit(const SellerRoleDone());
    } catch (_) {
      emit(const SellerRoleFailure(SellerRoleFailureReason.saveFailed));
    }
  }
}
