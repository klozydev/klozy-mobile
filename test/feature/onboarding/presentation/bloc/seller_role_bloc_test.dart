import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/me/entity/me_profile.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:klozy/src/feature/onboarding/presentation/bloc/seller_role_bloc.dart';
import 'package:klozy/src/feature/onboarding/presentation/bloc/seller_role_event.dart';
import 'package:klozy/src/feature/onboarding/presentation/bloc/seller_role_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockMeRepository extends Mock implements MeRepository {}

Future<List<SellerRoleState>> _collectStates(
  SellerRoleBloc bloc,
  SellerRoleEvent event,
) async {
  final states = <SellerRoleState>[];
  final sub = bloc.stream.listen(states.add);
  bloc.add(event);
  await Future<void>.delayed(Duration.zero);
  await sub.cancel();
  return states;
}

void main() {
  late _MockMeRepository mockRepo;
  late SellerRoleBloc bloc;

  setUpAll(() {
    registerFallbackValue(SellerRole.particular);
  });

  setUp(() {
    mockRepo = _MockMeRepository();
    bloc = SellerRoleBloc(mockRepo);
  });

  tearDown(() => bloc.close());

  test('initial state is SellerRoleIdle', () {
    expect(bloc.state, const SellerRoleIdle());
  });

  group('SellerRoleSubmitted', () {
    test('emits [SellerRoleSubmitting, SellerRoleDone] on success', () async {
      when(
        () => mockRepo.setSellerRole(
          role: any(named: 'role'),
          iban: any(named: 'iban'),
        ),
      ).thenAnswer((_) async {});

      final states = await _collectStates(
        bloc,
        const SellerRoleSubmitted(role: SellerRole.particular),
      );

      expect(states, [const SellerRoleSubmitting(), const SellerRoleDone()]);
    });

    test('emits [SellerRoleSubmitting, SellerRoleFailure] on error', () async {
      when(
        () => mockRepo.setSellerRole(
          role: any(named: 'role'),
          iban: any(named: 'iban'),
        ),
      ).thenThrow(Exception('server'));

      final states = await _collectStates(
        bloc,
        const SellerRoleSubmitted(role: SellerRole.vendor, iban: 'AE123'),
      );

      expect(states.first, const SellerRoleSubmitting());
      expect(states.last, isA<SellerRoleFailure>());
    });

    test('passes role and iban to repository', () async {
      when(
        () => mockRepo.setSellerRole(
          role: any(named: 'role'),
          iban: any(named: 'iban'),
        ),
      ).thenAnswer((_) async {});

      await _collectStates(
        bloc,
        const SellerRoleSubmitted(role: SellerRole.vendor, iban: 'AE123'),
      );

      verify(
        () => mockRepo.setSellerRole(role: SellerRole.vendor, iban: 'AE123'),
      ).called(1);
    });
  });
}
