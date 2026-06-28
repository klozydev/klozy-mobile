import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/auth/auth_exception.dart';
import 'package:klozy/src/domain/auth/auth_repository.dart';
import 'package:klozy/src/domain/auth/entity/auth_user.dart';
import 'package:klozy/src/domain/me/entity/me_profile.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:klozy/src/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:klozy/src/feature/auth/presentation/bloc/auth_event.dart';
import 'package:klozy/src/feature/auth/presentation/bloc/auth_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockMeRepository extends Mock implements MeRepository {}

Future<List<AuthState>> _collectStates(AuthBloc bloc, AuthEvent event) async {
  final states = <AuthState>[];
  final sub = bloc.stream.listen(states.add);
  bloc.add(event);
  await Future<void>.delayed(Duration.zero);
  await sub.cancel();
  return states;
}

const _kUser = AuthUser(uid: 'u1', email: 'test@example.com');
const _kCompleteMe = MeProfile(
  id: 'u1',
  firstName: 'Alice',
  lastName: 'Smith',
  hasAddress: true,
);
const _kIncompleteMe = MeProfile(id: 'u1');

void main() {
  late _MockAuthRepository mockAuth;
  late _MockMeRepository mockMe;
  late AuthBloc bloc;

  setUp(() {
    mockAuth = _MockAuthRepository();
    mockMe = _MockMeRepository();
    bloc = AuthBloc(mockAuth, mockMe);
  });

  tearDown(() => bloc.close());

  test('initial state is AuthIdle', () {
    expect(bloc.state, const AuthIdle());
  });

  // ── AuthEmailSubmitted (sign-in) ──────────────────────────────────────────

  group('AuthEmailSubmitted - sign in', () {
    test('emits [AuthLoading, AuthSuccess(complete)] on success', () async {
      when(
        () => mockAuth.signInWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => _kUser);
      when(() => mockMe.getMe()).thenAnswer((_) async => _kCompleteMe);

      final states = await _collectStates(
        bloc,
        const AuthEmailSubmitted(
          email: 'test@example.com',
          password: 'pw',
          isSignUp: false,
        ),
      );

      expect(states, [
        const AuthLoading(),
        const AuthSuccess(_kUser, onboardingComplete: true),
      ]);
    });

    test(
      'emits [AuthLoading, AuthSuccess(incomplete)] when profile incomplete',
      () async {
        when(
          () => mockAuth.signInWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => _kUser);
        when(() => mockMe.getMe()).thenAnswer((_) async => _kIncompleteMe);

        final states = await _collectStates(
          bloc,
          const AuthEmailSubmitted(
            email: 'test@example.com',
            password: 'pw',
            isSignUp: false,
          ),
        );

        expect(states, [
          const AuthLoading(),
          const AuthSuccess(_kUser, onboardingComplete: false),
        ]);
      },
    );

    test('treats /me failure as onboardingComplete=true (safety)', () async {
      when(
        () => mockAuth.signInWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => _kUser);
      when(() => mockMe.getMe()).thenThrow(Exception('network'));

      final states = await _collectStates(
        bloc,
        const AuthEmailSubmitted(
          email: 'test@example.com',
          password: 'pw',
          isSignUp: false,
        ),
      );

      expect(states.last, const AuthSuccess(_kUser, onboardingComplete: true));
    });

    test('emits [AuthLoading, AuthFailure] on AuthException', () async {
      when(
        () => mockAuth.signInWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const AuthException('Wrong password'));

      final states = await _collectStates(
        bloc,
        const AuthEmailSubmitted(
          email: 'test@example.com',
          password: 'pw',
          isSignUp: false,
        ),
      );

      expect(states, [
        const AuthLoading(),
        const AuthFailure('Wrong password'),
      ]);
    });

    test('emits [AuthLoading, AuthFailure] on generic exception', () async {
      when(
        () => mockAuth.signInWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(Exception('unknown'));

      final states = await _collectStates(
        bloc,
        const AuthEmailSubmitted(
          email: 'test@example.com',
          password: 'pw',
          isSignUp: false,
        ),
      );

      expect(states.first, const AuthLoading());
      expect(states.last, isA<AuthFailure>());
    });
  });

  // ── AuthEmailSubmitted (sign-up) ──────────────────────────────────────────

  group('AuthEmailSubmitted - sign up', () {
    test('calls signUpWithEmail on success', () async {
      when(
        () => mockAuth.signUpWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => _kUser);
      when(() => mockMe.getMe()).thenAnswer((_) async => _kCompleteMe);

      await _collectStates(
        bloc,
        const AuthEmailSubmitted(
          email: 'test@example.com',
          password: 'pw',
          isSignUp: true,
        ),
      );

      verify(
        () => mockAuth.signUpWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).called(1);
    });
  });

  // ── AuthGooglePressed ────────────────────────────────────────────────────

  group('AuthGooglePressed', () {
    test('emits [AuthLoading, AuthSuccess] on success', () async {
      when(() => mockAuth.signInWithGoogle()).thenAnswer((_) async => _kUser);
      when(() => mockMe.getMe()).thenAnswer((_) async => _kCompleteMe);

      final states = await _collectStates(bloc, const AuthGooglePressed());

      expect(states.first, const AuthLoading());
      expect(states.last, isA<AuthSuccess>());
    });

    test('emits [AuthLoading, AuthFailure] on error', () async {
      when(
        () => mockAuth.signInWithGoogle(),
      ).thenThrow(const AuthException('cancelled'));

      final states = await _collectStates(bloc, const AuthGooglePressed());

      expect(states, [const AuthLoading(), const AuthFailure('cancelled')]);
    });
  });

  // ── AuthApplePressed ────────────────────────────────────────────────────

  group('AuthApplePressed', () {
    test('emits [AuthLoading, AuthSuccess] on success', () async {
      when(() => mockAuth.signInWithApple()).thenAnswer((_) async => _kUser);
      when(() => mockMe.getMe()).thenAnswer((_) async => _kCompleteMe);

      final states = await _collectStates(bloc, const AuthApplePressed());

      expect(states.first, const AuthLoading());
      expect(states.last, isA<AuthSuccess>());
    });

    test('emits [AuthLoading, AuthFailure] on error', () async {
      when(
        () => mockAuth.signInWithApple(),
      ).thenThrow(Exception('apple error'));

      final states = await _collectStates(bloc, const AuthApplePressed());

      expect(states.last, isA<AuthFailure>());
    });
  });

  // ── AuthPasswordResetRequested ──────────────────────────────────────────

  group('AuthPasswordResetRequested', () {
    test('emits [AuthLoading, AuthPasswordResetSent] on success', () async {
      when(() => mockAuth.sendPasswordReset(any())).thenAnswer((_) async {});

      final states = await _collectStates(
        bloc,
        const AuthPasswordResetRequested('test@example.com'),
      );

      expect(states, [const AuthLoading(), const AuthPasswordResetSent()]);
    });

    test('emits [AuthLoading, AuthFailure] on error', () async {
      when(
        () => mockAuth.sendPasswordReset(any()),
      ).thenThrow(const AuthException('Email not found'));

      final states = await _collectStates(
        bloc,
        const AuthPasswordResetRequested('test@example.com'),
      );

      expect(states, [
        const AuthLoading(),
        const AuthFailure('Email not found'),
      ]);
    });
  });

  // ── AuthPhoneStarted ──────────────────────────────────────────────────────

  group('AuthPhoneStarted', () {
    test('emits [AuthLoading, AuthCodeSent] on success', () async {
      const verification = PhoneVerification(verificationId: 'vid-1');
      when(
        () => mockAuth.startPhoneVerification(any()),
      ).thenAnswer((_) async => verification);

      final states = await _collectStates(
        bloc,
        const AuthPhoneStarted('+971501234567'),
      );

      expect(states.first, const AuthLoading());
      final last = states.last;
      expect(last, isA<AuthCodeSent>());
      expect((last as AuthCodeSent).destination, '+971501234567');
    });

    test('emits [AuthLoading, AuthFailure] on error', () async {
      when(
        () => mockAuth.startPhoneVerification(any()),
      ).thenThrow(const AuthException('invalid phone'));

      final states = await _collectStates(
        bloc,
        const AuthPhoneStarted('+971501234567'),
      );

      expect(states, [const AuthLoading(), const AuthFailure('invalid phone')]);
    });
  });

  // ── AuthPhoneCodeSubmitted ────────────────────────────────────────────────

  group('AuthPhoneCodeSubmitted', () {
    test('emits [AuthLoading, AuthSuccess] on success', () async {
      when(
        () => mockAuth.confirmPhoneCode(
          verificationId: any(named: 'verificationId'),
          smsCode: any(named: 'smsCode'),
        ),
      ).thenAnswer((_) async => _kUser);
      when(() => mockMe.getMe()).thenAnswer((_) async => _kCompleteMe);

      final states = await _collectStates(
        bloc,
        const AuthPhoneCodeSubmitted(verificationId: 'vid', smsCode: '123456'),
      );

      expect(states.first, const AuthLoading());
      expect(states.last, isA<AuthSuccess>());
    });

    test('emits [AuthLoading, AuthFailure] on wrong code', () async {
      when(
        () => mockAuth.confirmPhoneCode(
          verificationId: any(named: 'verificationId'),
          smsCode: any(named: 'smsCode'),
        ),
      ).thenThrow(const AuthException('Invalid code'));

      final states = await _collectStates(
        bloc,
        const AuthPhoneCodeSubmitted(verificationId: 'vid', smsCode: '000000'),
      );

      expect(states, [const AuthLoading(), const AuthFailure('Invalid code')]);
    });
  });
}
