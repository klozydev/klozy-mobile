import 'package:klozy/src/core/network/base_url/base_url.dart';

/// Dev/staging API host. There is no separate staging deployment yet, so this
/// falls back to production — override per run with
/// `--dart-define=KLOZY_BASE_URL=https://staging…`.
class DevBaseUrl extends BaseUrl {
  @override
  String baseUrl = const String.fromEnvironment(
    'KLOZY_BASE_URL',
    defaultValue: 'https://klozy-api-production.up.railway.app/',
  );
}
