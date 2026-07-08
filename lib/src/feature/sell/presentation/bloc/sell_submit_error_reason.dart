/// Why submitting (publishing) a listing failed. Carried by [SellRecapState]
/// instead of a hardcoded English string; the UI maps it to a localized message.
///
/// l10n mapping (ui-dev, in the SellRecapState listener):
///   SellSubmitErrorReason.publishFailed -> context.l10N.sell_publish_failed
enum SellSubmitErrorReason {
  /// Creating / publishing the product failed.
  publishFailed,
}
