import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/domain/auth/auth_exception.dart';
import 'package:klozy/src/domain/auth/auth_repository.dart';
import 'package:klozy/src/domain/auth/entity/auth_user.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:klozy/src/feature/auth/presentation/bloc/auth_event.dart';
import 'package:klozy/src/feature/auth/presentation/bloc/auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final MeRepository _meRepository;

  AuthBloc(this._authRepository, this._meRepository) : super(const AuthIdle()) {
    on<AuthEmailSubmitted>(_onEmail);
    on<AuthGooglePressed>(_onGoogle);
    on<AuthApplePressed>(_onApple);
    on<AuthPasswordResetRequested>(_onPasswordReset);
    on<AuthPhoneStarted>(_onPhoneStarted);
    on<AuthPhoneCodeSubmitted>(_onPhoneCode);
  }

  Future<void> _onEmail(AuthEmailSubmitted event, Emitter<AuthState> emit) {
    return _guard(emit, () async {
      final user = event.isSignUp
          ? await _authRepository.signUpWithEmail(
              email: event.email,
              password: event.password,
            )
          : await _authRepository.signInWithEmail(
              email: event.email,
              password: event.password,
            );
      await _finishAuth(user, emit);
    });
  }

  Future<void> _onGoogle(AuthGooglePressed event, Emitter<AuthState> emit) {
    return _guard(
      emit,
      () async => _finishAuth(await _authRepository.signInWithGoogle(), emit),
    );
  }

  Future<void> _onApple(AuthApplePressed event, Emitter<AuthState> emit) {
    return _guard(
      emit,
      () async => _finishAuth(await _authRepository.signInWithApple(), emit),
    );
  }

  Future<void> _onPasswordReset(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) {
    return _guard(emit, () async {
      await _authRepository.sendPasswordReset(event.email);
      emit(const AuthPasswordResetSent());
    });
  }

  Future<void> _onPhoneStarted(
    AuthPhoneStarted event,
    Emitter<AuthState> emit,
  ) {
    return _guard(emit, () async {
      final verification = await _authRepository.startPhoneVerification(
        event.phoneNumber,
        resendToken: event.resendToken,
      );
      final autoUser = verification.autoSignedInUser;
      if (autoUser != null) {
        // Android instant verification: already signed in — no OTP entry.
        await _finishAuth(autoUser, emit);
        return;
      }
      emit(
        AuthCodeSent(
          verification: verification,
          destination: event.phoneNumber,
        ),
      );
    });
  }

  Future<void> _onPhoneCode(
    AuthPhoneCodeSubmitted event,
    Emitter<AuthState> emit,
  ) {
    return _guard(emit, () async {
      final user = await _authRepository.confirmPhoneCode(
        verificationId: event.verificationId,
        smsCode: event.smsCode,
      );
      await _finishAuth(user, emit);
    });
  }

  /// Resolves the post-auth route by checking profile completeness via
  /// `GET /v1/me` (which also provisions the user on first call).
  Future<void> _finishAuth(AuthUser user, Emitter<AuthState> emit) async {
    bool complete;
    try {
      complete = (await _meRepository.getMe()).isProfileComplete;
    } catch (_) {
      complete = true; // don't trap the user if /me is unreachable
    }
    emit(AuthSuccess(user, onboardingComplete: complete));
  }

  Future<void> _guard(
    Emitter<AuthState> emit,
    Future<void> Function() action,
  ) async {
    emit(const AuthLoading());
    try {
      await action();
    } on AuthException catch (e) {
      emit(AuthFailure(e.message));
    } catch (_) {
      emit(const AuthFailure('Something went wrong. Please try again.'));
    }
  }
}
