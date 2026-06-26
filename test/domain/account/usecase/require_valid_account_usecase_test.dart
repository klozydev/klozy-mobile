import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/account/entity/account_status.dart';
import 'package:klozy/src/domain/account/usecase/get_account_status_usecase.dart';
import 'package:klozy/src/domain/account/usecase/require_valid_account_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetAccountStatusUseCase extends Mock
    implements GetAccountStatusUseCase {}

void main() {
  late _MockGetAccountStatusUseCase mockGetStatus;
  late RequireValidAccountUseCase useCase;

  setUp(() {
    mockGetStatus = _MockGetAccountStatusUseCase();
    useCase = RequireValidAccountUseCase(mockGetStatus);
  });

  group('RequireValidAccountUseCase.call', () {
    for (final status in AccountStatus.values) {
      test(
        'delegates to GetAccountStatusUseCase and returns $status',
        () async {
          when(() => mockGetStatus()).thenAnswer((_) async => status);

          final result = await useCase();

          expect(result, status);
          verify(() => mockGetStatus()).called(1);
        },
      );
    }
  });

  group('RequireValidAccountUseCase.isValid', () {
    test('returns true only for AccountStatus.valid', () async {
      when(() => mockGetStatus()).thenAnswer((_) async => AccountStatus.valid);

      expect(await useCase.isValid(), isTrue);
    });

    test('returns false for AccountStatus.guest', () async {
      when(() => mockGetStatus()).thenAnswer((_) async => AccountStatus.guest);

      expect(await useCase.isValid(), isFalse);
    });

    test('returns false for AccountStatus.legacy', () async {
      when(() => mockGetStatus()).thenAnswer((_) async => AccountStatus.legacy);

      expect(await useCase.isValid(), isFalse);
    });

    test('returns false for AccountStatus.incompleteOnboarding', () async {
      when(
        () => mockGetStatus(),
      ).thenAnswer((_) async => AccountStatus.incompleteOnboarding);

      expect(await useCase.isValid(), isFalse);
    });
  });
}
