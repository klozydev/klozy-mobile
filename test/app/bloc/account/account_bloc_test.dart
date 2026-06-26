import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/app/bloc/account/account_bloc.dart';
import 'package:klozy/src/app/bloc/account/account_event.dart';
import 'package:klozy/src/app/bloc/account/account_state.dart';
import 'package:klozy/src/domain/account/entity/account_status.dart';
import 'package:klozy/src/domain/account/usecase/get_account_status_usecase.dart';
import 'package:klozy/src/domain/auth/auth_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetAccountStatusUseCase extends Mock
    implements GetAccountStatusUseCase {}

class _MockAuthRepository extends Mock implements AuthRepository {}

/// Dispatches [event] to [bloc], collects all emitted states until the handler
/// completes, and returns them in order.
Future<List<AccountState>> _collectStates(
  AccountBloc bloc,
  AccountEvent event,
) async {
  final states = <AccountState>[];
  final sub = bloc.stream.listen(states.add);
  bloc.add(event);
  await Future<void>.delayed(Duration.zero);
  await sub.cancel();
  return states;
}

void main() {
  late _MockGetAccountStatusUseCase mockUseCase;
  late _MockAuthRepository mockAuthRepository;
  late AccountBloc bloc;

  setUp(() {
    mockUseCase = _MockGetAccountStatusUseCase();
    mockAuthRepository = _MockAuthRepository();
    // signOut is a no-op in most tests unless overridden.
    when(() => mockAuthRepository.signOut()).thenAnswer((_) async {});
    bloc = AccountBloc(mockUseCase, mockAuthRepository);
  });

  tearDown(() => bloc.close());

  group('AccountBloc - AccountBootstrapRequested', () {
    test(
      'emits [AccountResolving, AccountResolved(valid)] for a valid account',
      () async {
        when(() => mockUseCase()).thenAnswer((_) async => AccountStatus.valid);

        final states = await _collectStates(
          bloc,
          const AccountBootstrapRequested(),
        );

        expect(states, <AccountState>[
          const AccountResolving(),
          const AccountResolved(AccountStatus.valid),
        ]);
        verifyNever(() => mockAuthRepository.signOut());
      },
    );

    test(
      'emits [AccountResolving, AccountResolved(guest)] when no Firebase user',
      () async {
        when(() => mockUseCase()).thenAnswer((_) async => AccountStatus.guest);

        final states = await _collectStates(
          bloc,
          const AccountBootstrapRequested(),
        );

        expect(states, <AccountState>[
          const AccountResolving(),
          const AccountResolved(AccountStatus.guest),
        ]);
        verifyNever(() => mockAuthRepository.signOut());
      },
    );

    test('legacy: calls signOut then emits AccountResolved(guest)', () async {
      when(() => mockUseCase()).thenAnswer((_) async => AccountStatus.legacy);

      final states = await _collectStates(
        bloc,
        const AccountBootstrapRequested(),
      );

      // The stale session must be cleaned up before the resolved state.
      verify(() => mockAuthRepository.signOut()).called(1);
      expect(states, <AccountState>[
        const AccountResolving(),
        // After signOut the user is a clean guest.
        const AccountResolved(AccountStatus.guest),
      ]);
    });

    test(
      'emits [AccountResolving, AccountResolved(incompleteOnboarding)] when profile incomplete',
      () async {
        when(
          () => mockUseCase(),
        ).thenAnswer((_) async => AccountStatus.incompleteOnboarding);

        final states = await _collectStates(
          bloc,
          const AccountBootstrapRequested(),
        );

        expect(states, <AccountState>[
          const AccountResolving(),
          const AccountResolved(AccountStatus.incompleteOnboarding),
        ]);
        verifyNever(() => mockAuthRepository.signOut());
      },
    );

    test('initial state is AccountInitial', () {
      expect(bloc.state, const AccountInitial());
    });

    test('calls GetAccountStatusUseCase exactly once per bootstrap', () async {
      when(() => mockUseCase()).thenAnswer((_) async => AccountStatus.valid);

      await _collectStates(bloc, const AccountBootstrapRequested());

      verify(() => mockUseCase()).called(1);
    });

    test('re-bootstrap after onboarding completion transitions from '
        'incompleteOnboarding to valid', () async {
      // First bootstrap: profile was incomplete.
      when(
        () => mockUseCase(),
      ).thenAnswer((_) async => AccountStatus.incompleteOnboarding);
      await _collectStates(bloc, const AccountBootstrapRequested());
      expect(
        bloc.state,
        const AccountResolved(AccountStatus.incompleteOnboarding),
      );

      // Profile is now complete — re-bootstrap (triggered by
      // ProfileCompletionPage on ProfileCompletionDone).
      when(() => mockUseCase()).thenAnswer((_) async => AccountStatus.valid);

      final states = await _collectStates(
        bloc,
        const AccountBootstrapRequested(),
      );

      expect(states, <AccountState>[
        const AccountResolving(),
        const AccountResolved(AccountStatus.valid),
      ]);
      expect(bloc.state, const AccountResolved(AccountStatus.valid));
    });
  });
}
