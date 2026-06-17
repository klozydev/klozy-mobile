/// What a seller still needs before they can list, derived from the Klozy
/// profile + Stripe Connect status:
///
/// - [ready] — role set and payout path satisfied; open the Sell flow.
/// - [needsRole] — `MeProfile.sellerRole == null`; route to SellerRoleRoute.
/// - [needsAddress] — seller has no default shipping address; route to the
///   address form. Without it (line1/city/phone) the EMX ship call returns 400.
/// - [needsIban] — particular seller without `payoutIbanMasked`; route to the
///   IBAN setup (PayoutRoute / address+IBAN onboarding).
/// - [needsKyb] — vendor whose `ConnectStatus.onboarding != complete`; route to
///   SellerVerificationRoute.
enum SellPrerequisite { ready, needsRole, needsAddress, needsIban, needsKyb }
