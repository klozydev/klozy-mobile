/// Why posting a reel failed. Carried by [ReelComposerReady] instead of a
/// hardcoded English string; the UI maps it to a localized message.
///
/// l10n mapping (ui-dev, in the ReelComposerReady listener):
///   ReelComposerErrorReason.postFailed -> context.l10N.reels_composer_post_failed
enum ReelComposerErrorReason {
  /// Creating / uploading the reel failed.
  postFailed,
}
