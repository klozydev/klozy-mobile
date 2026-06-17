import 'package:injectable/injectable.dart';
import 'package:klozy/src/domain/me/entity/connect_status.dart';
import 'package:klozy/src/domain/me/entity/me_profile.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:klozy/src/domain/sell/usecase/sell_prerequisite.dart';

/// Decides what (if anything) blocks the current user from listing, by combining
/// `MeProfile.sellerRole` + `payoutIbanMasked` with `ConnectStatus`:
///
/// - sellerRole == null              → [SellPrerequisite.needsRole]
/// - particular & payoutIbanMasked   == null → [SellPrerequisite.needsIban]
/// - vendor & Connect not complete   → [SellPrerequisite.needsKyb]
/// - otherwise                       → [SellPrerequisite.ready]
///
/// "Complete" for a vendor means ConnectOnboarding.complete AND chargesEnabled.
///
/// Assumes the caller is already a valid account (the Sell entry is gated by
/// [AccountGate] first).
@injectable
class CheckSellPrerequisiteUseCase {
  final MeRepository _meRepository;

  CheckSellPrerequisiteUseCase(this._meRepository);

  Future<SellPrerequisite> call() async {
    final profile = await _meRepository.getMe();

    // No seller role chosen yet.
    if (profile.sellerRole == null) {
      return SellPrerequisite.needsRole;
    }

    // Every seller (particular or vendor) must have a default shipping address
    // on file — the EMX label needs the seller's line1/city/phone, otherwise
    // POST /v1/orders/:id/ship returns 400 once they have a sale.
    if (!profile.hasAddress) {
      return SellPrerequisite.needsAddress;
    }

    if (profile.sellerRole == SellerRole.particular) {
      // Particular seller needs a payout IBAN on file.
      if (profile.payoutIbanMasked == null) {
        return SellPrerequisite.needsIban;
      }
      return SellPrerequisite.ready;
    }

    // Vendor: require Stripe Connect onboarding complete and charges enabled.
    final connect = await _meRepository.getConnectStatus();
    final connectReady =
        connect.onboarding == ConnectOnboarding.complete &&
        connect.chargesEnabled;
    if (!connectReady) {
      return SellPrerequisite.needsKyb;
    }

    return SellPrerequisite.ready;
  }
}
