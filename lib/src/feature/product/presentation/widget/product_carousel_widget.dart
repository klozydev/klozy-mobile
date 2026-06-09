import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_pill_indicator.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/domain/product/entity/product_detail.dart';

/// Full-bleed 3:4 photo carousel with pill indicator, counter, scrims and a
/// SOLD/RESERVED stamp when blocked.
class ProductCarouselWidget extends StatefulWidget {
  final List<String> images;
  final ProductStatus status;

  const ProductCarouselWidget({
    super.key,
    required this.images,
    required this.status,
  });

  @override
  State<ProductCarouselWidget> createState() => _ProductCarouselWidgetState();
}

class _ProductCarouselWidgetState extends State<ProductCarouselWidget> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.sizeOf(context).width * 4 / 3;
    final bool blocked = widget.status != ProductStatus.active;
    final images = widget.images;
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (images.isEmpty)
            const ColoredBox(color: DSColor.lowBlack)
          else
            PageView.builder(
              controller: _controller,
              itemCount: images.length,
              onPageChanged: (int i) => setState(() => _index = i),
              itemBuilder: (BuildContext context, int i) =>
                  Image.network(images[i], fit: BoxFit.cover),
            ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Color(0x73000000),
                  Colors.transparent,
                  Color(0x66000000),
                ],
                stops: <double>[0, 0.35, 1],
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
          if (images.length > 1)
            Positioned(
              bottom: 14,
              left: 0,
              right: 0,
              child: Center(
                child: DSPillIndicator(
                  count: images.length,
                  activeIndex: _index,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
