import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/core/image/app_image_cache_manager.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/domain/product/entity/product_detail.dart';
import 'package:klozy/src/feature/product/presentation/widget/product_carousel_image_widget.dart';

/// Full-bleed photo carousel with SOLD/RESERVED stamp when blocked.
/// Delegates page-indicator rendering to [ProductPageDotsWidget] via [onPageChanged].
class ProductCarouselWidget extends StatefulWidget {
  final List<String> images;
  final ProductStatus status;
  final ValueChanged<int>? onPageChanged;

  const ProductCarouselWidget({
    super.key,
    required this.images,
    required this.status,
    this.onPageChanged,
  });

  @override
  State<ProductCarouselWidget> createState() => _ProductCarouselWidgetState();
}

class _ProductCarouselWidgetState extends State<ProductCarouselWidget> {
  final PageController _controller = PageController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Warm the first two frames so the opening photo and the first swipe are
    // instant even on a cold cache.
    _precache(0);
    _precache(1);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Decode-and-cache the image at [index] (if it exists) ahead of time.
  void _precache(int index) {
    if (index < 0 || index >= widget.images.length) return;
    precacheImage(
      CachedNetworkImageProvider(
        widget.images[index],
        cacheManager: AppImageCacheManager.instance,
      ),
      context,
    );
  }

  void _onPageChanged(int index) {
    // Prefetch the neighbours so the next swipe never waits on the network.
    _precache(index + 1);
    _precache(index - 1);
    widget.onPageChanged?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    final bool blocked = widget.status != ProductStatus.active;
    final List<String> images = widget.images;
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        if (images.isEmpty)
          const ColoredBox(color: DSColor.lowBlack)
        else
          // ExcludeSemantics prevents off-screen PageView pages from leaving
          // dirty semantics nodes in PipelineOwner.flushSemantics. When a
          // BackdropFilter (DSGlassButton in ProductTopBarWidget) coexists with
          // a nested viewport (PageView inside SingleChildScrollView), the
          // framework's debugCheckForParentData assert fires every frame because
          // RenderViewport.visitChildrenForSemantics excludes non-visible pages
          // while the surrounding BackdropFilter forces a semantics pass each
          // frame. Excluding the carousel from the semantics tree stops those
          // nodes from ever becoming dirty. Semantic context for the images is
          // provided by ProductTitleBlockWidget and ProductPageDotsWidget.
          ExcludeSemantics(
            child: PageView.builder(
              controller: _controller,
              itemCount: images.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (BuildContext context, int i) =>
                  ProductCarouselImageWidget(imageUrl: images[i]),
            ),
          ),
        if (blocked)
          Center(
            child: Transform.rotate(
              angle: -0.16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xCCFFFFFF),
                    width: 2.5,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.status == ProductStatus.sold
                      ? context.l10N.product_stamp_sold
                      : context.l10N.product_stamp_reserved,
                  style: const TextStyle(
                    fontFamily: dsFontFamily,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.9,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
