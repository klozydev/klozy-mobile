import 'package:flutter/material.dart';
import 'package:klozy/src/feature/product/presentation/widget/product_carousel_photo_widget.dart';

/// A single full-bleed carousel photo.
///
/// The product is shown in full (via [ProductCarouselPhotoWidget]) so nothing is
/// cropped or over-zoomed, regardless of the photo's aspect ratio. The letterbox
/// around the photo is filled with the photo's own edge colors so it bleeds into
/// the background with no visible rectangular border.
///
/// The page is kept alive ([AutomaticKeepAliveClientMixin]) so that once a photo
/// has been shown, swiping away and back does NOT rebuild it: without this,
/// [PageView] disposes off-screen pages and the returning page would restart the
/// image load state (and re-sample its edge colors), flashing the shimmer again
/// even on a warm disk cache. Keeping the state makes back-swipes instant, like a
/// real carousel.
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
    return ProductCarouselPhotoWidget(imageUrl: widget.imageUrl);
  }
}
