import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/feature/reels/domain/entity/reel.dart';
import 'package:klozy/src/feature/reels/presentation/widget/reel_action_widget.dart';
import 'package:klozy/src/router/app_router.dart';
import 'package:video_player/video_player.dart';

/// A single full-bleed reel page: looping video (or poster) + tap-to-pause +
/// engagement overlay.
class ReelPageWidget extends StatefulWidget {
  final Reel reel;
  final bool isActive;
  final bool isOwner;
  final VoidCallback onLike;
  final VoidCallback onShop;
  final VoidCallback onShare;
  final VoidCallback onMenu;
  final VoidCallback onComments;

  const ReelPageWidget({
    super.key,
    required this.reel,
    required this.isActive,
    required this.isOwner,
    required this.onLike,
    required this.onShop,
    required this.onShare,
    required this.onMenu,
    required this.onComments,
  });

  @override
  State<ReelPageWidget> createState() => _ReelPageWidgetState();
}

class _ReelPageWidgetState extends State<ReelPageWidget> {
  VideoPlayerController? _controller;
  bool _ready = false;
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    final url = widget.reel.playbackUrl;
    if (url != null) {
      final controller = VideoPlayerController.networkUrl(Uri.parse(url))
        ..setLooping(true);
      _controller = controller;
      controller.initialize().then((_) {
        if (!mounted) return;
        setState(() => _ready = true);
        if (widget.isActive) controller.play();
      });
    }
  }

  @override
  void didUpdateWidget(ReelPageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller?.play();
        _paused = false;
      } else {
        _controller?.pause();
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    final controller = _controller;
    if (controller == null) return;
    setState(() {
      if (controller.value.isPlaying) {
        controller.pause();
        _paused = true;
      } else {
        controller.play();
        _paused = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final reel = widget.reel;
    return GestureDetector(
      onTap: _togglePlay,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          ColoredBox(color: DSColor.surface, child: _videoOrPoster()),
          // Bottom scrim for the caption / actions.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                colors: <Color>[Colors.transparent, Color(0xB3000000)],
              ),
            ),
          ),
          if (_paused)
            const Center(
              child: Icon(
                Icons.play_arrow_rounded,
                size: 64,
                color: Color(0xD9FFFFFF),
              ),
            ),
          _rail(context, reel),
          _caption(context, reel),
        ],
      ),
    );
  }

  Widget _videoOrPoster() {
    final controller = _controller;
    if (_ready && controller != null) {
      return FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.size.width,
          height: controller.value.size.height,
          child: VideoPlayer(controller),
        ),
      );
    }
    if (widget.reel.posterUrl != null) {
      return Image.network(widget.reel.posterUrl!, fit: BoxFit.cover);
    }
    return const SizedBox.shrink();
  }

  Widget _rail(BuildContext context, Reel reel) {
    return Positioned(
      right: 12,
      bottom: 26,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ReelActionWidget(
            icon: reel.isLiked ? Icons.favorite : Icons.favorite_border,
            label: '${reel.likes}',
            color: reel.isLiked ? DSColor.danger : Colors.white,
            onTap: widget.onLike,
          ),
          const SizedBox(height: 22),
          ReelActionWidget(
            icon: Icons.mode_comment_outlined,
            label: context.l10N.reels_comments_label,
            onTap: widget.onComments,
          ),
          const SizedBox(height: 22),
          ReelActionWidget(
            icon: Icons.shopping_bag_outlined,
            label: '${reel.taggedCount}',
            onTap: widget.onShop,
          ),
          const SizedBox(height: 22),
          ReelActionWidget(
            icon: Icons.ios_share_rounded,
            label: context.l10N.reels_share,
            onTap: widget.onShare,
          ),
          const SizedBox(height: 22),
          ReelActionWidget(icon: Icons.more_horiz, onTap: widget.onMenu),
        ],
      ),
    );
  }

  Widget _caption(BuildContext context, Reel reel) {
    return Positioned(
      left: 16,
      right: 80,
      bottom: 26,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => context.router.push(
                  UserProfileRoute(userId: reel.author.id),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CircleAvatar(
                      radius: 19,
                      backgroundColor: DSColor.lowBlack,
                      backgroundImage: reel.author.avatarUrl == null
                          ? null
                          : NetworkImage(reel.author.avatarUrl!),
                      child: reel.author.avatarUrl == null
                          ? const Icon(
                              Icons.person,
                              size: 20,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 180),
                      child: Text(
                        reel.author.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: dsFontFamily,
                          fontSize: DSFontSize.bodyLarge,
                          fontWeight: DSFontWeight.semiBold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (reel.author.isPro) ...<Widget>[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: DSColor.primary,
                    borderRadius: BorderRadius.circular(DSBorderRadius.chip),
                  ),
                  child: const Text(
                    'PRO',
                    style: TextStyle(
                      fontFamily: dsFontFamily,
                      fontSize: 9,
                      fontWeight: DSFontWeight.bold,
                      letterSpacing: 0.54,
                      color: DSColor.surface,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (reel.caption.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            Text(
              reel.caption,
              style: const TextStyle(
                fontFamily: dsFontFamily,
                fontSize: DSFontSize.bodyMedium,
                height: 1.38,
                color: Color(0xF2FFFFFF),
                shadows: <Shadow>[
                  Shadow(color: Color(0x99000000), blurRadius: 4),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          GestureDetector(
            onTap: widget.onShop,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0x29FFFFFF),
                borderRadius: BorderRadius.circular(DSBorderRadius.chip),
                border: Border.all(color: const Color(0x40FFFFFF), width: 0.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(
                    Icons.shopping_bag_outlined,
                    size: 15,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    context.l10N.reels_shop_the_look_count(reel.taggedCount),
                    style: const TextStyle(
                      fontFamily: dsFontFamily,
                      fontSize: DSFontSize.bodyMedium,
                      fontWeight: DSFontWeight.semiBold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
