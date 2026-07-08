import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Shared, tuned disk cache for every remote image in the app.
///
/// `cached_network_image`'s default manager keeps only 200 objects for 30 days,
/// which evicts aggressively on an image-heavy marketplace feed and forces
/// re-downloads (the "images reload when I come back" symptom). This manager
/// raises the object budget so already-seen product photos, avatars and
/// thumbnails stay on disk across sessions.
///
/// Exposed as a static singleton so the design-system [DSNetworkImage] can reach
/// it synchronously in `build` without coupling the design layer to GetIt; the
/// same instance is also registered in DI (`AppModule`) for service-layer use
/// and test overrides.
abstract final class AppImageCacheManager {
  static const String key = 'klozyImageCache';

  static final CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 800,
    ),
  );
}
