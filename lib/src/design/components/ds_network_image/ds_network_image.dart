import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/core/image/app_image_cache_manager.dart';
import 'package:klozy/src/design/components/ds_network_image/ds_network_image_shape.dart';
import 'package:klozy/src/design/components/shimmer_box/shimmer_box_widget.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';

/// The single entry point for every remote image in the app.
///
/// Wraps [CachedNetworkImage] so that, for free, each image:
/// - persists to the shared tuned disk cache ([AppImageCacheManager]) — no
///   re-download when the user returns to a list or reopens a product;
/// - shows an animated [ShimmerBoxWidget] while loading instead of a bare box;
/// - is decoded downsampled to its layout width ([cacheWidth]) so large source
///   photos render fast and cheaply;
/// - fades in only briefly, so a cache hit feels instant.
///
/// Use it in place of `Image.network` / `NetworkImage` everywhere. Pass
/// [fallback] for the null/empty/error state (e.g. an avatar monogram).
class DSNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final DSNetworkImageShape shape;

  /// Corner radius when [shape] is [DSNetworkImageShape.rounded].
  final double borderRadius;

  /// Shown when [imageUrl] is null/empty or fails to load. Defaults to a
  /// broken-image glyph on [DSColor.card].
  final Widget? fallback;

  /// Logical width the decoded bitmap is downsampled to (physical pixels are
  /// derived from the device ratio). Defaults to [width] when it is finite.
  /// Pass a small value for heavily-scaled or blurred sources.
  final double? cacheWidth;

  const DSNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.shape = DSNetworkImageShape.rounded,
    this.borderRadius = DSBorderRadius.light,
    this.fallback,
    this.cacheWidth,
  });

  bool get _isCircle => shape == DSNetworkImageShape.circle;

  double get _effectiveRadius {
    if (!_isCircle) return borderRadius;
    final double? side = width ?? height;
    return side != null ? side / 2 : DSBorderRadius.heavy;
  }

  @override
  Widget build(BuildContext context) {
    final Widget resolvedFallback = fallback ?? _defaultFallback();

    if (imageUrl == null || imageUrl!.isEmpty) {
      return _clip(resolvedFallback);
    }

    final double? decodeWidth = cacheWidth ?? width;
    final double dpr = MediaQuery.devicePixelRatioOf(context);
    final int? memCacheWidth =
        (decodeWidth != null && decodeWidth.isFinite && decodeWidth > 0)
        ? (decodeWidth * dpr).round()
        : null;

    return _clip(
      CachedNetworkImage(
        imageUrl: imageUrl!,
        cacheManager: AppImageCacheManager.instance,
        width: width,
        height: height,
        fit: fit,
        memCacheWidth: memCacheWidth,
        fadeInDuration: const Duration(milliseconds: 150),
        fadeOutDuration: Duration.zero,
        placeholder: (BuildContext context, String url) => ShimmerBoxWidget(
          width: width,
          height: height,
          borderRadius: _effectiveRadius,
        ),
        errorWidget: (BuildContext context, String url, Object error) =>
            resolvedFallback,
      ),
    );
  }

  Widget _clip(Widget child) {
    if (_isCircle) {
      return ClipOval(child: child);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: child,
    );
  }

  Widget _defaultFallback() {
    return Container(
      width: width,
      height: height,
      color: DSColor.card,
      alignment: Alignment.center,
      child: const Icon(
        Icons.broken_image_outlined,
        color: DSColor.onSurface45,
      ),
    );
  }
}
