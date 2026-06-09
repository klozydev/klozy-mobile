import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:klozy/src/feature/onboarding/presentation/bloc/profile_completion_event.dart';
import 'package:klozy/src/feature/onboarding/presentation/bloc/profile_completion_state.dart';

@injectable
class ProfileCompletionBloc
    extends Bloc<ProfileCompletionEvent, ProfileCompletionState> {
  final MeRepository _meRepository;

  ProfileCompletionBloc(this._meRepository)
    : super(const ProfileCompletionIdle()) {
    on<ProfileCompletionSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    ProfileCompletionSubmitted event,
    Emitter<ProfileCompletionState> emit,
  ) async {
    emit(const ProfileCompletionSubmitting());
    try {
      await _meRepository.updateProfile(
        firstName: event.firstName,
        lastName: event.lastName,
        bio: event.bio,
      );
      await _meRepository.setAddress(event.address);
      emit(const ProfileCompletionDone());
    } catch (_) {
      emit(
        const ProfileCompletionFailure(
          "Couldn't save your profile. Please try again.",
        ),
      );
    }
  }
}
