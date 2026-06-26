import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/me/entity/connect_status.dart';
import 'package:klozy/src/domain/me/entity/me_profile.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:klozy/src/domain/sell/usecase/check_sell_prerequisite_usecase.dart';
import 'package:klozy/src/domain/sell/usecase/sell_prerequisite.dart';
import 'package:mocktail/mocktail.dart';

class _MockMeRepository extends Mock implements MeRepository {}

/// A [ConnectStatus] where onboarding is complete and charges are enabled.
const _connectReady = ConnectStatus(
  accountId: 'acct_123',
  onboarding: ConnectOnboarding.complete,
  detailsSubmitted: true,
  chargesEnabled: true,
  payoutsEnabled: true,
);

/// A [ConnectStatus] where onboarding is still pending.
const _connectPending = ConnectStatus(
  onboarding: ConnectOnboarding.pending,
  detailsSubmitted: false,
  chargesEnabled: false,
);

/// A [ConnectStatus] where onboarding is complete but charges are NOT enabled.
const _connectCompleteNoCharges = ConnectStatus(
  accountId: 'acct_123',
  onboarding: ConnectOnboarding.complete,
  detailsSubmitted: true,
  chargesEnabled: false,
);

void main() {
  late _MockMeRepository mockMe;
  late CheckSellPrerequisiteUseCase useCase;

  setUp(() {
    mockMe = _MockMeRepository();
    useCase = CheckSellPrerequisiteUseCase(mockMe);
  });

  group('CheckSellPrerequisiteUseCase', () {
    test('returns needsRole when sellerRole is null', () async {
      when(
        () => mockMe.getMe(),
      ).thenAnswer((_) async => const MeProfile(id: 'u1'));

      final result = await useCase();

      expect(result, SellPrerequisite.needsRole);
      verifyNever(() => mockMe.getConnectStatus());
    });

    test(
      'returns needsIban for particular seller without payoutIbanMasked',
      () async {
        when(() => mockMe.getMe()).thenAnswer(
          (_) async => const MeProfile(
            id: 'u1',
            sellerRole: SellerRole.particular,
            hasAddress: true,
            payoutIbanMasked: null,
          ),
        );

        final result = await useCase();

        expect(result, SellPrerequisite.needsIban);
        verifyNever(() => mockMe.getConnectStatus());
      },
    );

    test('returns ready for particular seller with payoutIbanMasked', () async {
      when(() => mockMe.getMe()).thenAnswer(
        (_) async => const MeProfile(
          id: 'u1',
          sellerRole: SellerRole.particular,
          hasAddress: true,
          payoutIbanMasked: 'FR76 **** 1234',
        ),
      );

      final result = await useCase();

      expect(result, SellPrerequisite.ready);
      verifyNever(() => mockMe.getConnectStatus());
    });

    test(
      'returns needsKyb for vendor with pending Connect onboarding',
      () async {
        when(() => mockMe.getMe()).thenAnswer(
          (_) async => const MeProfile(
            id: 'u1',
            sellerRole: SellerRole.vendor,
            hasAddress: true,
          ),
        );
        when(
          () => mockMe.getConnectStatus(),
        ).thenAnswer((_) async => _connectPending);

        final result = await useCase();

        expect(result, SellPrerequisite.needsKyb);
      },
    );

    test(
      'returns needsKyb for vendor with complete onboarding but chargesEnabled false',
      () async {
        when(() => mockMe.getMe()).thenAnswer(
          (_) async => const MeProfile(
            id: 'u1',
            sellerRole: SellerRole.vendor,
            hasAddress: true,
          ),
        );
        when(
          () => mockMe.getConnectStatus(),
        ).thenAnswer((_) async => _connectCompleteNoCharges);

        final result = await useCase();

        expect(result, SellPrerequisite.needsKyb);
      },
    );

    test(
      'returns ready for vendor with complete Connect and chargesEnabled',
      () async {
        when(() => mockMe.getMe()).thenAnswer(
          (_) async => const MeProfile(
            id: 'u1',
            sellerRole: SellerRole.vendor,
            hasAddress: true,
          ),
        );
        when(
          () => mockMe.getConnectStatus(),
        ).thenAnswer((_) async => _connectReady);

        final result = await useCase();

        expect(result, SellPrerequisite.ready);
      },
    );
  });
}
