/// Why saving the seller role failed. Carried by [SellerRoleFailure] instead of
/// a hardcoded English string; the UI maps it to a localized message.
///
/// l10n mapping (ui-dev, in the SellerRoleFailure listener):
///   SellerRoleFailureReason.saveFailed -> context.l10N.settings_save_failed
enum SellerRoleFailureReason {
  /// Persisting the seller role / IBAN failed.
  saveFailed,
}
