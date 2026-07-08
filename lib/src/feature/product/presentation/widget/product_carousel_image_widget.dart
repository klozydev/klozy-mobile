import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/core/image/app_image_cache_manager.dart';
import 'package:klozy/src/design/components/ds_network_image/ds_network_image.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';

/// A single full-bleed carousel photo.
///
/// The product is always shown in full via [BoxFit.contain] so nothing is
/// cropped or over-zoomed, regardless of the photo's aspect ratio. To avoid
/// dead bars around portrait/landscape shots, a blurred, cover-fitted copy of
/// the same image fills the frame behind it, dimmed by [DSColor.photoBackdropScrim].
///
/// Both layers read from the shared tuned disk cache ([AppImageCacheManager]);
/// the foreground shows an animated shimmer while loading and the blurred
/// backdrop is decoded tiny (the blur hides the low resolution) so it is cheap.
///
/// The page is kept alive ([AutomaticKeepAliveClientMixin]) so that once a photo
/// has been shown, swiping away and back does NOT rebuild it: without this,
/// [PageView] disposes off-screen pages and the returning page would restart
/// [CachedNetworkImage]'s load state, flashing the shimmer again even on a warm
/// disk cache. Keeping the state makes back-swipes instant, like a real carousel.
class ProductCarouselImageWidget extends StatefulWidget {
  final String imageUrl;

  const ProductCarouselImageWidget({super.key, required this.imageUrl});

  @override
  State<ProductCarouselImageWidget> createState() =>
      _ProductCarouselImageWidgetState();
}

class _ProductCarouselImageWidgetState extends State<ProductCarouselImageWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final double screenWidth = MediaQuery.sizeOf(context).width;
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        // Blurred backdrop fills the frame so the screen never shows bare
        // surface bars around photos whose ratio differs from the screen.
        // Decoded at a tiny width — the heavy blur makes the low resolution
        // invisible, so this layer costs almost nothing.
        ImageFiltered(
          imageFilter: ui.ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: CachedNetworkImage(
            imageUrl: widget.imageUrl,
            cacheManager: AppImageCacheManager.instance,
            fit: BoxFit.cover,
            memCacheWidth: 64,
            fadeInDuration: const Duration(milliseconds: 150),
            fadeOutDuration: Duration.zero,
            placeholder: (BuildContext context, String url) =>
                const ColoredBox(color: DSColor.card),
            errorWidget: (BuildContext context, String url, Object error) =>
                const ColoredBox(color: DSColor.card),
          ),
        ),
        const ColoredBox(color: DSColor.photoBackdropScrim),
        // The product itself, shown in full over the backdrop.
        DSNetworkImage(
          imageUrl: widget.imageUrl,
          fit: BoxFit.contain,
          borderRadius: DSBorderRadius.none,
          cacheWidth: screenWidth,
          fallback: const Center(
            child: Icon(
              Icons.broken_image_outlined,
              color: DSColor.onSurface45,
            ),
          ),
        ),
      ],
    );
  }
}
