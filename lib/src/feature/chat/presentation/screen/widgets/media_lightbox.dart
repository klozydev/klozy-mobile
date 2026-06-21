import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:video_player/video_player.dart';

/// Fullscreen media viewer (image pan/zoom, or autoplaying video with controls).
/// Pushed as a fullscreen dialog route.
class MediaLightbox extends StatefulWidget {
  const MediaLightbox({super.key, required this.url, required this.isVideo});

  final String url;
  final bool isVideo;

  static Future<void> open(
    BuildContext context, {
    required String url,
    required bool isVideo,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => MediaLightbox(url: url, isVideo: isVideo),
      ),
    );
  }

  @override
  State<MediaLightbox> createState() => _MediaLightboxState();
}

class _MediaLightboxState extends State<MediaLightbox> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.isVideo) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
        ..initialize().then((_) {
          if (!mounted) return;
          setState(() {});
          _controller?.play();
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColor.surface,
      body: Stack(
        children: <Widget>[
          Center(child: _content()),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 8,
            right: 18,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: DSColor.onSurface12,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: DSColor.onSurface,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _content() {
    if (widget.isVideo) {
      final VideoPlayerController? c = _controller;
      if (c == null || !c.value.isInitialized) {
        return const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(DSColor.primary),
        );
      }
      return GestureDetector(
        onTap: () => setState(() => c.value.isPlaying ? c.pause() : c.play()),
        child: AspectRatio(
          aspectRatio: c.value.aspectRatio,
          child: VideoPlayer(c),
        ),
      );
    }
    return InteractiveViewer(
      minScale: 1,
      maxScale: 4,
      child: Image.network(widget.url, fit: BoxFit.contain),
    );
  }
}
