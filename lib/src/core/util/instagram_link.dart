/// The admin stores Instagram as a handle (e.g. `@klozy_uae` or just
/// `klozy_uae`), not a full URL. Strip a leading `@` and resolve to
/// `instagram.com/<handle>` so url_launcher gets a real URL and the OS hands it
/// to the Instagram app (or browser) instead of silently failing on a
/// scheme-less string. A value that is already a full URL is passed through.
String instagramUrl(String value) {
  final trimmed = value.trim();
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }
  final handle = trimmed.startsWith('@') ? trimmed.substring(1) : trimmed;
  return 'https://instagram.com/$handle';
}

/// Pretty-print whatever the admin entered as a handle prefixed with `@`,
/// even if they pasted a full URL or left the `@` off.
String instagramHandleDisplay(String value) {
  final trimmed = value.trim();
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    final segments = Uri.parse(trimmed).pathSegments;
    final handle = segments.isNotEmpty ? segments.first : trimmed;
    return '@$handle';
  }
  return trimmed.startsWith('@') ? trimmed : '@$trimmed';
}
