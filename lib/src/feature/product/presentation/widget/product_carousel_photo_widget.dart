import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/core/image/app_image_cache_manager.dart';
import 'package:klozy/src/design/components/shimmer_box/shimmer_box_widget.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/feature/product/presentation/widget/edge_feather_widget.dart';
import 'package:klozy/src/feature/product/presentation/widget/product_carousel_backdrop_widget.dart';

/// The sharp product photo layer of the carousel: shown in full over a backdrop
/// built from the photo's own edge colors, so it bleeds into the background
/// instead of showing a hard rectangle (see [ProductCarouselBackdropWidget]).
///
/// The photo is laid out at its intrinsic aspect ratio ([Center] > [AspectRatio])
/// and painted with [BoxFit.cover] so it exactly fills that box — visually the
/// same as [BoxFit.contain], but with the paint box aligned to the image so the
/// letterbox bars can be color-matched and the boundary feathered
/// ([EdgeFeatherWidget]) along the barred axis only.
///
/// Both the ratio and the four edge colors are read once from a tiny decode of
/// the image (the average is all that is needed, and downscaling already blends
/// each edge). Until that resolves a shimmer stands in; a broken-image glyph is
/// shown on failure.
class ProductCarouselPhotoWidget extends StatefulWidget {
  final String imageUrl;

  const ProductCarouselPhotoWidget({super.key, required this.imageUrl});

  @override
  State<ProductCarouselPhotoWidget> createState() =>
      _ProductCarouselPhotoWidgetState();
}

class _ProductCarouselPhotoWidgetState
    extends State<ProductCarouselPhotoWidget> {
  /// Width the edge-color probe is decoded to. Tiny by design.
  static const int _probeWidth = 48;

  ImageStream? _probeStream;
  ImageStreamListener? _probeListener;
  double? _ratio;
  Color? _topColor;
  Color? _bottomColor;
  Color? _leftColor;
  Color? _rightColor;
  bool _failed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveProbe();
  }

  @override
  void didUpdateWidget(ProductCarouselPhotoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _ratio = null;
      _topColor = null;
      _bottomColor = null;
      _leftColor = null;
      _rightColor = null;
      _failed = false;
      _resolveProbe();
    }
  }

  @override
  void dispose() {
    _detachProbe();
    super.dispose();
  }

  /// Resolve a tiny decode of the image (shared disk cache) and listen for it so
  /// the intrinsic ratio and edge colors can be sampled.
  void _resolveProbe() {
    final ImageProvider<Object> probe = ResizeImage.resizeIfNeeded(
      _probeWidth,
      null,
      CachedNetworkImageProvider(
        widget.imageUrl,
        cacheManager: AppImageCacheManager.instance,
      ),
    );
    final ImageStream stream = probe.resolve(
      createLocalImageConfiguration(context),
    );
    if (stream.key == _probeStream?.key) return;
    _detachProbe();
    _probeStream = stream;
    _probeListener = ImageStreamListener(_onProbe, onError: _onError);
    stream.addListener(_probeListener!);
  }

  void _onProbe(ImageInfo info, bool synchronousCall) {
    unawaited(_ingest(info.image));
  }

  Future<void> _ingest(ui.Image image) async {
    final int w = image.width;
    final int h = image.height;
    final double ratio = h == 0 ? 1 : w / h;
    final ByteData? data = await image.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    );
    if (!mounted) return;
    if (data == null || w <= 0 || h <= 0) {
      setState(() {
        _ratio = ratio;
        _topColor = DSColor.surface;
        _bottomColor = DSColor.surface;
        _leftColor = DSColor.surface;
        _rightColor = DSColor.surface;
      });
      return;
    }
    final Uint8List bytes = data.buffer.asUint8List();
    setState(() {
      _ratio = ratio;
      _topColor = _averageRow(bytes, w, 0);
      _bottomColor = _averageRow(bytes, w, h - 1);
      _leftColor = _averageColumn(bytes, w, h, 0);
      _rightColor = _averageColumn(bytes, w, h, w - 1);
    });
  }

  void _onError(Object error, StackTrace? stackTrace) {
    if (!mounted) return;
    setState(() => _failed = true);
  }

  void _detachProbe() {
    final ImageStreamListener? listener = _probeListener;
    if (listener != null) {
      _probeStream?.removeListener(listener);
    }
    _probeListener = null;
  }

  static Color _averageRow(Uint8List bytes, int width, int y) {
    int r = 0;
    int g = 0;
    int b = 0;
    final int base = y * width * 4;
    for (int x = 0; x < width; x++) {
      final int i = base + x * 4;
      r += bytes[i];
      g += bytes[i + 1];
      b += bytes[i + 2];
    }
    return Color.fromARGB(255, r ~/ width, g ~/ width, b ~/ width);
  }

  static Color _averageColumn(Uint8List bytes, int width, int height, int x) {
    int r = 0;
    int g = 0;
    int b = 0;
    for (int y = 0; y < height; y++) {
      final int i = (y * width + x) * 4;
      r += bytes[i];
      g += bytes[i + 1];
      b += bytes[i + 2];
    }
    return Color.fromARGB(255, r ~/ height, g ~/ height, b ~/ height);
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return const Center(
        child: Icon(Icons.broken_image_outlined, color: DSColor.onSurface45),
      );
    }
    final double? ratio = _ratio;
    final Color? topColor = _topColor;
    if (ratio == null || topColor == null) {
      return const ShimmerBoxWidget(borderRadius: DSBorderRadius.none);
    }

    final double dpr = MediaQuery.devicePixelRatioOf(context);
    final double screenWidth = MediaQuery.sizeOf(context).width;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool topBottom =
            ratio >= constraints.maxWidth / constraints.maxHeight;
        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            ProductCarouselBackdropWidget(
              imageRatio: ratio,
              topColor: topColor,
              bottomColor: _bottomColor!,
              leftColor: _leftColor!,
              rightColor: _rightColor!,
            ),
            Center(
              child: AspectRatio(
                aspectRatio: ratio,
                child: EdgeFeatherWidget(
                  axis: topBottom ? Axis.vertical : Axis.horizontal,
                  child: CachedNetworkImage(
                    imageUrl: widget.imageUrl,
                    cacheManager: AppImageCacheManager.instance,
                    fit: BoxFit.cover,
                    memCacheWidth: (screenWidth * dpr).round(),
                    fadeInDuration: const Duration(milliseconds: 150),
                    fadeOutDuration: Duration.zero,
                    placeholder: (BuildContext context, String url) =>
                        const ShimmerBoxWidget(
                          borderRadius: DSBorderRadius.none,
                        ),
                    errorWidget:
                        (BuildContext context, String url, Object error) =>
                            const Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: DSColor.onSurface45,
                              ),
                            ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
