import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/domain/product/entity/product_detail.dart';

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
  void dispose() {
    _controller.dispose();
    super.dispose();
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
              onPageChanged: widget.onPageChanged,
              itemBuilder: (BuildContext context, int i) => CachedNetworkImage(
                imageUrl: images[i],
                fit: BoxFit.cover,
                placeholder: (BuildContext context, String url) =>
                    const ColoredBox(color: DSColor.card),
                errorWidget: (BuildContext context, String url, Object error) =>
                    const ColoredBox(
                      color: DSColor.card,
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: DSColor.onSurface45,
                      ),
                    ),
              ),
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
